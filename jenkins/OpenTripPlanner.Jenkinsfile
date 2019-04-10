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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/dolmit/OpenTripPlanner.git']]])
            }
        }
        stage('Extract mvn cache') {
            steps {
              sh 'docker run --rm --entrypoint tar "peatusee.azurecr.io/opentripplanner-estonia:builder" -c /root/.m2|tar x -C ./'
              sh 'ls -l'
            }
        }
        stage('Docker Build image builder') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/opentripplanner-estonia:builder -f Dockerfile.builder .'
            }
        }
        stage('Docker Push image builder') {
            steps {
              sh 'docker push peatusee.azurecr.io/opentripplanner-estonia:builder'
            }
        }
        stage('Create targets') {
            steps {
              sh 'mkdir export'
              sh 'docker run --rm --entrypoint tar "peatusee.azurecr.io/opentripplanner-estonia:builder" -c target|tar x -C ./'
            }
        }
        stage('Docker Build image') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/opentripplanner-estonia:latest -f Dockerfile .'
            }
        }
        stage('Docker Push image') {
            steps {
              sh 'docker push peatusee.azurecr.io/opentripplanner-estonia:latest'
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/opentripplanner-estonia/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
