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
                sh "docker rm -f pelias_elasticsearch || exit 0"
                sh 'rm -rf /pelias-data/elasticsearch'
                sh 'pelias compose pull'
                sh 'pelias elastic start'
                sh 'pelias elastic wait'
                sh 'pelias elastic create'
                sh 'pelias download all'
                sh 'pelias prepare all'
                sh 'pelias import all || exit 0'
                sh "cp Dockerfile.* /pelias-data/"
                sh "cp elasticsearch.yml /pelias-data/"
                sh 'cp docker-pelias.json /pelias-data/docker-pelias.json'
                sh "docker rm -f pelias_elasticsearch || exit 0"
              }
            }
        }
        stage('Docker Build images') {
            steps {
                sh 'cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-elastic:latest -f Dockerfile.elasticsearch .'
                sh 'cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-api:latest -f Dockerfile.pelias-api .'
                sh 'cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-interpolation:latest -f Dockerfile.interpolation .'
                sh 'cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-pip:latest -f Dockerfile.pip .'
                sh 'cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-placeholder:latest -f Dockerfile.placeholder .'
                sh 'cd /pelias-data/ && docker build --tag=peatusee.azurecr.io/pelias-libpostal:latest -f Dockerfile.libpostal .'
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
    }
}
