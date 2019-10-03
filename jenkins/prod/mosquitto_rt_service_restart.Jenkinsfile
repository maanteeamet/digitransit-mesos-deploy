pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timestamps()
    }
    stages {
        stage('Mesos restart container') {
            steps {
              sh 'ssh azureuser@peatusee-prod-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/mosquitto-server/restart"'
              sh 'ssh azureuser@peatusee-prod-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/rt-estonia-vehicles-service/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
