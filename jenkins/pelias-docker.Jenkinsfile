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

                sh "docker stop pelias_elasticsearch || exit 0"
                sh "cp Dockerfile.* /pelias-data/"
                sh "cp elasticsearch.yml /pelias-data/"
                sh 'cp pelias.json /pelias-data/'
              }
            }
        }
        stage('Docker Build images') {
            steps {
              dir("/pelias-data") {
                sh 'docker build --tag=peatusee.azurecr.io/pelias-elastic:latest -f Dockerfile.elasticsearch .'
                sh 'docker build --tag=peatusee.azurecr.io/pelias-api:latest -f Dockerfile.pelias-api .'
              }
            }
        }
        stage('Docker Push images') {
            steps {
              dir("/pelias-data") {
                sh 'docker push peatusee.azurecr.io/pelias-elastic:latest'
                sh 'docker push peatusee.azurecr.io/pelias-api:latest'
              }
            }
        }
    }
}
