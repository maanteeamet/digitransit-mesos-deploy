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
              checkout([$class: 'GitSCM', branches: [[name: '*/estonia']], userRemoteConfigs: [[url: 'https://github.com/herrbpl/pelias-docker.git']]])
            }
        }
        stage('Build map data') {
            steps {
              dir("projects/estonia") {
                sh "mkdir -p /pelias-data/tiger/shapefiles || exit 0"
                sh "sed -i '/DATA_DIR/d' .env && echo 'DATA_DIR=/pelias-data' >> .env"
                sh "sed -i '/DOCKER_USER/d' .env && echo 'DOCKER_USER=996' >> .env"
                sh "docker rm -f pelias_elasticsearch pelias_pip-service || exit 0"
                sh 'rm -rf /pelias-data/elasticsearch'
                sh 'pelias compose pull'
                sh 'pelias elastic start'
                sh 'pelias elastic wait'
                sh 'pelias elastic create'
                sh 'pelias download all'
                sh 'pelias prepare all'
                sh 'pelias import all || exit 0'
                sh "pelias compose run pelias-gtfs"
                sh 'sleep 10 && pelias elastic stop'
                sh "cp Dockerfile.* /pelias-data/"
                sh "cp elasticsearch.yml /pelias-data/"
                sh 'cp docker-pelias.json /pelias-data/docker-pelias.json'
                sh "docker rm -f pelias_elasticsearch pelias_pip-service || exit 0"
              }
            }
        }
        stage('Docker Build images') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
              dir("projects/estonia") {
                sh 'cp Dockerignore.elasticsearch /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-elastic:latest -f Dockerfile.elasticsearch .'
                sh 'cp Dockerignore.interpolation /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-interpolation:latest -f Dockerfile.interpolation .'
                sh 'cp Dockerignore.pip /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-pip:latest -f Dockerfile.pip .'
                sh 'cp Dockerignore.placeholder /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-placeholder:latest -f Dockerfile.placeholder .'
                sh 'cp Dockerignore.libpostal /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-libpostal:latest -f Dockerfile.libpostal .'
				sh "docker tag peatusee.azurecr.io/pelias-elastic:latest peatusee.azurecr.io/pelias-elastic:${env.BUILD_ID}-${commit_id}"
				sh "docker tag peatusee.azurecr.io/pelias-interpolation:latest peatusee.azurecr.io/pelias-interpolation:${env.BUILD_ID}-${commit_id}"
				sh "docker tag peatusee.azurecr.io/pelias-pip:latest peatusee.azurecr.io/pelias-pip:${env.BUILD_ID}-${commit_id}"
				sh "docker tag peatusee.azurecr.io/pelias-placeholder:latest peatusee.azurecr.io/pelias-placeholder:${env.BUILD_ID}-${commit_id}"
				sh "docker tag peatusee.azurecr.io/pelias-libpostal:latest peatusee.azurecr.io/pelias-libpostal:${env.BUILD_ID}-${commit_id}"
              }
            }
        }
        stage('Docker Push images') {
			environment {
				commit_id = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)	
			  }
            steps {
                sh 'docker push peatusee.azurecr.io/pelias-elastic:latest'
                sh 'docker push peatusee.azurecr.io/pelias-interpolation:latest'
                sh 'docker push peatusee.azurecr.io/pelias-pip:latest'
                sh 'docker push peatusee.azurecr.io/pelias-placeholder:latest'
                sh 'docker push peatusee.azurecr.io/pelias-libpostal:latest'
				sh "docker push peatusee.azurecr.io/pelias-elastic:${env.BUILD_ID}-${commit_id}"
				sh "docker push peatusee.azurecr.io/pelias-interpolation:${env.BUILD_ID}-${commit_id}"
				sh "docker push peatusee.azurecr.io/pelias-pip:${env.BUILD_ID}-${commit_id}"
				sh "docker push peatusee.azurecr.io/pelias-placeholder:${env.BUILD_ID}-${commit_id}"
				sh "docker push peatusee.azurecr.io/pelias-libpostal:${env.BUILD_ID}-${commit_id}"
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-data-container/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-pip/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-placeholder/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-libpostal/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-interpolation/restart"'
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
            mail bcc: '', body: "<b>Build failure email</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: 'Jenkins', mimeType: 'text/html', replyTo: '', subject: "Build failure from Jenkins: Project - ${env.JOB_NAME}", to: "anu@dolmit.com";
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
