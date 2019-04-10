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
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine npm install'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine npm install gulp-cli'
            }
        }
        stage('Run gulp') {
            steps {
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp seed'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp osm:update'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp gtfs:dl'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp gtfs:fit'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp gtfs:filter'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp gtfs:id'
              sh 'docker run -it -w /data --rm -v.:/data node:10-alpine gulp router:buildGraph'
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
