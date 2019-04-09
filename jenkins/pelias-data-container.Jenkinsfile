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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/dolmit/pelias-data-container.git']]])
            }
        }
        stage('Docker Build image pelias-data-container-base') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/pelias-data-container-base:latest -f Dockerfile.base .'
            }
        }
        stage('Docker Push image pelias-data-container-base') {
            steps {
              sh 'docker push peatusee.azurecr.io/pelias-data-container-base:latest'
            }
        }
        stage('Docker Build image pelias-data-container-builder') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/pelias-data-container-builder:latest -f Dockerfile.builder .'
            }
        }
        stage('Docker Push image pelias-data-container-builder') {
            steps {
              sh 'docker push peatusee.azurecr.io/pelias-data-container-builder:latest'
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-data-container-builder/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
