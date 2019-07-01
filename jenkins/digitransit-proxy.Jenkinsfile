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
              checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[url: 'https://github.com/maanteeamet/digitransit-proxy.git']]])
			  def commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)			  
            }
        }
        stage('Docker Build image') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/digitransit-proxy:latest .'
			  sh "docker tag peatusee.azurecr.io/digitransit-proxy:latest peatusee.azurecr.io/digitransit-proxy:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Docker Push image') {
            steps {
              sh 'docker push peatusee.azurecr.io/digitransit-proxy:latest'
			  sh "docker push peatusee.azurecr.io/digitransit-proxy:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/digitransit-proxy/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
