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
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {			  
              sh 'docker build --tag=peatusee.azurecr.io/digitransit-proxy:latest .'
			  sh "docker tag peatusee.azurecr.io/digitransit-proxy:latest peatusee.azurecr.io/digitransit-proxy:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Docker Push image') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }		
            steps {
              sh 'docker push peatusee.azurecr.io/digitransit-proxy:latest'
			  sh "docker push peatusee.azurecr.io/digitransit-proxy:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/digitransit-proxy/restart"'
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
