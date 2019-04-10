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
        stage('Run deploy.sh') {
            steps {
              sh './deploy.sh estonia'
            }
        }
        stage('Push data container') {
            steps {
              sh 'docker push peatusee.azurecr.io/opentripplanner-data-container-estonia'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
