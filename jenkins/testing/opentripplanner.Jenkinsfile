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
              sh 'ssh azureuser@peatusee-testing-acsmgmt.westeurope.cloudapp.azure.com "curl  -H \'Content-Type: application/json\' -X POST http://127.0.0.1:80/service/marathon/v2/apps/opentripplanner-estonia/restart"'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
