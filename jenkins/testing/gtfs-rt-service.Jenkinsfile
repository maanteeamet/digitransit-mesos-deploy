pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
	parameters {
        string(name: 'source_tag', defaultValue: 'latest', description: 'Docker image with this tag will be pulled from registry, tagged with "testing" tag and pushed back.')
    }
    stages {
        stage('Docker Pull,Tag and Push') {
            steps {
			  sh "docker pull peatusee.azurecr.io/gtfs-rt-server:${params.source_tag}"
			  sh "docker tag peatusee.azurecr.io/gtfs-rt-server:${params.source_tag} peatusee.azurecr.io/gtfs-rt-server:testing"
			  sh "docker push peatusee.azurecr.io/gtfs-rt-server:testing"
            }
        }

        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-testing-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/gtfs-rt-server/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
