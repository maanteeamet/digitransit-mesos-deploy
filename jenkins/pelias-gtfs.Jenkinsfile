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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/maanteeamet/pelias-gtfs.git']]])
            }
        }
        stage('Docker Build image') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
                sh 'docker build --tag=peatusee.azurecr.io/pelias-gtfs:latest -f Dockerfile .'
				sh "docker tag peatusee.azurecr.io/pelias-gtfs:latest peatusee.azurecr.io/pelias-gtfs:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Docker Push images') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
                sh 'docker push peatusee.azurecr.io/pelias-gtfs:latest'
				sh "docker push peatusee.azurecr.io/pelias-gtfs:${env.BUILD_ID}-${commit_id}"
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
