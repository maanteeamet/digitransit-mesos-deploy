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
              checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[url: 'https://github.com/maanteeamet/rt-estonia-vehicles-service.git']]])
            }
        }
        stage('Docker Build image') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/rt-estonia-vehicles-service:latest .'
			  sh "docker tag peatusee.azurecr.io/rt-estonia-vehicles-service:latest peatusee.azurecr.io/rt-estonia-vehicles-service:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Docker Push image') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              sh 'docker push peatusee.azurecr.io/rt-estonia-vehicles-service:latest'
			  sh "docker push peatusee.azurecr.io/rt-estonia-vehicles-service:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/rt-estonia-vehicles-service/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
