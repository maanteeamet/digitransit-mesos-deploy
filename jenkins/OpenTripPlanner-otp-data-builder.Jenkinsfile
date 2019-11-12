pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
   environment {
       ROUTERS = "estonia"
       SEED_TAG = "latest"
       OTP_TAG = "latest"
       TOOLS_TAG = "latest"
       DOCKER_TAG = "latest"
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
        stage('Docker remove old unused images') {
            steps {
              sh 'docker system prune -f'
            }
        }
        stage('Docker Build image otp-data-builder') {
            steps {
              sh 'docker build --tag=peatusee.azurecr.io/otp-data-builder:latest .'
            }
        }
        stage('Docker Push image otp-data-builder') {
            steps {
              sh 'docker push peatusee.azurecr.io/otp-data-builder:latest'
            }
        }
        stage('Docker Build image otp-data-tools') {
            steps {
              sh 'cd otp-data-tools && docker build --tag=peatusee.azurecr.io/otp-data-tools:latest .'
            }
        }
        stage('Docker Push image otp-data-tools') {
            steps {
              sh 'docker push peatusee.azurecr.io/otp-data-tools:latest'
            }
        }
        stage('Run gulp') {
            steps {
              sh 'gulp seed || exit 0'
              sh 'gulp osm:update'
              sh 'gulp gtfs:dl'
              sh 'gulp gtfs:fit'
              sh 'gulp gtfs:filter'
              sh 'gulp gtfs:id'
              sh 'gulp router:buildGraph'
              sh 'find data'
            }
        }
        stage('Create container opentripplanner-data-container-estonia') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              dir("data/build/estonia/") {
                sh "docker build --tag=peatusee.azurecr.io/opentripplanner-data-container-estonia:latest -f Dockerfile.data-container ."
				sh "docker tag peatusee.azurecr.io/opentripplanner-data-container-estonia:latest peatusee.azurecr.io/opentripplanner-data-container-estonia:${env.BUILD_ID}-${commit_id}"
              }
            }
        }
        stage('Push data opentripplanner-data-container-estonia') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              sh 'docker push peatusee.azurecr.io/opentripplanner-data-container-estonia:latest'
			  sh "docker push peatusee.azurecr.io/opentripplanner-data-container-estonia:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Mesos restart container') {
            steps {
            
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/opentripplanner-data-con-estonia/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Build was successful'
        }
        failure {
            mail bcc: '', body: "<b>Build failure email</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: 'Jenkins', mimeType: 'text/html', replyTo: '', subject: "Build failure from Jenkins: Project - ${env.JOB_NAME}", to: "yhistransport@mnt.ee";
        }
        unstable {
            echo 'Run was marked as unstable'
        }
        changed {
            echo 'The state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
