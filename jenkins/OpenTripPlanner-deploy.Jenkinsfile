pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
   environment {
       ROUTERS = "estonia"
       
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
        stage('Run gulp') {
            steps {
              sh 'gulp seed'
              sh 'gulp osm:update'
              sh 'gulp gtfs:dl'
              sh 'gulp gtfs:fit'
              sh 'gulp gtfs:filter'
              sh 'gulp gtfs:id'
              sh 'gulp router:buildGraph'
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
