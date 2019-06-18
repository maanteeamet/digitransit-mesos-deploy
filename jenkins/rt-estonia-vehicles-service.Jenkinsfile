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
              checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[url: 'https://github.com/dolmit/rt-estonia-vehicles-service.git']]])
            }
        }
        stage('Docker Build image') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/rt-estonia-vehicles-service:latest .'
            }
        }
        stage('Docker Push image') {
            steps {
              sh 'docker push peatusee.azurecr.io/rt-estonia-vehicles-service:latest'
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
