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
              
              sh 'docker run -i -w /data --rm -v"$(pwd)":/data node:10-alpine npm install'
              sh 'docker run -i -w /data --rm -v"$(pwd)":/data node:10-alpine npm install gulp-cli'
            }
        }
        stage('Run gulp') {
            steps {
              sh './node_modules/.bin/gulp seed'
              sh './node_modules/.bin/gulp osm:update'
              sh './node_modules/.bin/gulp gtfs:dl'
              sh './node_modules/.bin/gulp gtfs:fit'
              sh './node_modules/.bin/gulp gtfs:filter'
              sh './node_modules/.bin/gulp gtfs:id'
              sh './node_modules/.bin/gulp router:buildGraph'
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
