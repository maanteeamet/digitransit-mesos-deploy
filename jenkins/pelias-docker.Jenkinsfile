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
            steps {
              dir("projects/estonia") {
                sh 'cp Dockerignore.elasticsearch /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-elastic:latest -f Dockerfile.elasticsearch .'
                sh 'cp Dockerignore.pelias-api /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-api:latest -f Dockerfile.pelias-api .'
                sh 'cp Dockerignore.interpolation /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-interpolation:latest -f Dockerfile.interpolation .'
                sh 'cp Dockerignore.pip /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-pip:latest -f Dockerfile.pip .'
                sh 'cp Dockerignore.placeholder /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-placeholder:latest -f Dockerfile.placeholder .'
                sh 'cp Dockerignore.libpostal /pelias-data/.dockerignore && cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-libpostal:latest -f Dockerfile.libpostal .'
              }
            }
        }
        stage('Docker Push images') {
            steps {
                sh 'docker push peatusee.azurecr.io/pelias-elastic:latest'
                sh 'docker push peatusee.azurecr.io/pelias-api:latest'
                sh 'docker push peatusee.azurecr.io/pelias-interpolation:latest'
                sh 'docker push peatusee.azurecr.io/pelias-pip:latest'
                sh 'docker push peatusee.azurecr.io/pelias-placeholder:latest'
                sh 'docker push peatusee.azurecr.io/pelias-libpostal:latest'
            }
        }
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-data-container/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-pip/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-placeholder/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-libpostal/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-interpolation/restart"'
              sh 'ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/pelias-api/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
