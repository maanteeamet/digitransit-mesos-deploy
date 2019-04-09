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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/dolmit/digitransit-ui.git']]])
            }
        }
        stage('Docker Build image') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/digitransit-ui:latest .'
            }
        }
        stage('Docker Push image') {
            steps {
              sh 'docker push peatusee.azurecr.io/digitransit-ui:latest'
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/digitransit-ui-default/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
