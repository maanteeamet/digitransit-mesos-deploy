pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
	parameters {
        string(name: 'pelias_source_tag', defaultValue: 'latest', description: 'Pelias DATA Docker image with this tag will be pulled from registry, tagged with "testing" tag and pushed back.')
		string(name: 'otp_source_tag', defaultValue: 'latest', description: 'OTP Data Docker image with this tag will be pulled from registry, tagged with "testing" tag and pushed back.')
    }
    stages {       
        stage('Docker Pull,Tag and Push') {					
            steps {			                
			  sh "docker pull peatusee.azurecr.io/opentripplanner-data-container-estonia:${params.otp_source_tag}"
			  sh "docker pull peatusee.azurecr.io/pelias-elastic:${params.pelias_source_tag}"
			  sh "docker tag peatusee.azurecr.io/opentripplanner-data-container-estonia:${params.otp_source_tag} peatusee.azurecr.io/opentripplanner-data-container-estonia:testing"
			  sh "docker push peatusee.azurecr.io/opentripplanner-data-container-estonia:testing"
			  sh "docker tag peatusee.azurecr.io/pelias-elastic:${params.pelias_source_tag} peatusee.azurecr.io/pelias-elastic:testing"
			  sh "docker push peatusee.azurecr.io/pelias-elastic:testing"
			  sh "docker rmi peatusee.azurecr.io/pelias-elastic:testing"
			  sh "docker rmi peatusee.azurecr.io/pelias-elastic:${params.pelias_source_tag}"
			  sh "docker rmi peatusee.azurecr.io/opentripplanner-data-container-estonia:testing"
			  sh "docker rmi peatusee.azurecr.io/opentripplanner-data-container-estonia:${params.otp_source_tag}"
            }
        }
        
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-testing-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/opentripplanner-data-con-estonia/restart"'
			  sh 'ssh azureuser@peatusee-testing-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-data-container/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
