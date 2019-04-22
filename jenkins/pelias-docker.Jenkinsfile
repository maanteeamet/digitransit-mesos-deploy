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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/dolmit/pelias-docker.git']]])
            }
        }
        stage('Docker Build image') {
            steps {
              dir("projects/estonia") {
                sh 'mkdir data || exit 0'
                sh "sed -i '/DATA_DIR/d' .env && echo 'DATA_DIR=data' >> .env"
                sh 'pelias compose pull'
                sh 'pelias elastic start'
                sh 'pelias elastic wait'
                sh 'pelias elastic create'
                sh 'pelias download all'
                sh 'pelias prepare all'
                sh 'pelias import all'
              }
            }
        }
    }
}
