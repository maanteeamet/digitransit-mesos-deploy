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
    }
}
