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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/dolmit/pelias-gtfs.git']]])
            }
        }
        stage('Docker Build image') {
            steps {
                sh 'docker build --tag=peatusee.azurecr.io/pelias-gtfs:latest -f Dockerfile .'
            }
        }
        stage('Docker Push images') {
            steps {
                sh 'docker push peatusee.azurecr.io/pelias-gtfs:latest'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
