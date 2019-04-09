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
            }
        }
        stage('Docker Build image') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/digitransit-proxy:latest .'
            }
        }
        stage('Docker Push image') {
            steps {
              sh 'docker push peatusee.azurecr.io/digitransit-proxy:latest'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
