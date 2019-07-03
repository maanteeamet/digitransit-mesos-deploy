pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
    stages {
        stage('Git checkout') {
            steps {
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/maanteeamet/pelias-api.git']]])
            }
        }
        stage('Fix configuration for mesos') {
            steps {
              sh 'perl -p -i -e "s/pelias_elasticsearch/pelias-data-container/g" pelias.json.docker'
            }
        }
        stage('Docker Build image') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/pelias-api:latest .'
			  sh "docker tag peatusee.azurecr.io/pelias-api:latest peatusee.azurecr.io/pelias-api:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Docker Push image') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              sh 'docker push peatusee.azurecr.io/pelias-api:latest'
			  sh "docker push peatusee.azurecr.io/pelias-api:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-api/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
