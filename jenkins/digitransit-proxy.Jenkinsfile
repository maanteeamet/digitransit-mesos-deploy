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
        stage('Build image') {
            steps {
              sh 'ls -l'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
