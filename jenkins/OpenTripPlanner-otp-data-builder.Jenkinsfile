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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/dolmit/OpenTripPlanner-data-container.git']]])
            }
        }
        stage('Run npm') {
            steps {
              sh 'npm install'
            }
        }
        stage('Docker Build image builder') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/otp-data-builder:latest .'
            }
        }
        stage('Docker Push image builder') {
            steps {
              sh 'docker push peatusee.azurecr.io/otp-data-builder:latest'
            }
        }
        stage('Docker Build image tools') {
            steps {
              sh 'cd otp-data-tools && docker build --tag=peatusee.azurecr.io/otp-data-tools:latest .'
            }
        }
        stage('Docker Push image tools') {
            steps {
              sh 'docker push peatusee.azurecr.io/otp-data-tools:latest'
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/otp-data-builder-dev/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
