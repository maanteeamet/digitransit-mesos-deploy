pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
	parameters {
        string(name: 'source_tag', defaultValue: 'testing', description: 'Docker image with this tag will be pulled from registry, tagged with "prod" tag and pushed back.')
    }
    stages {       
        stage('Docker Pull,Tag and Push') {					
            steps {			                
			  sh "docker pull peatusee.azurecr.io/digitransit-ui:${params.source_tag}"
			  sh "docker tag peatusee.azurecr.io/digitransit-ui:${params.source_tag} peatusee.azurecr.io/digitransit-ui:prod"
			  sh "docker push peatusee.azurecr.io/digitransit-ui:prod"
            }
        }
        
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-prod-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/digitransit-ui-default/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
