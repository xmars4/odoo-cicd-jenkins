pipeline {
    agent any

    environment {
        MY_VARIABLE = 'Hello, World!'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    sh './odoo-docker/scripts/build.sh'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    sh 'cat ./odoo-docker/logs/odoo.log|grep INFO'
                }
            }
        }
        stage('Deploy'){
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    echo 'Deploying...'
                    echo "current build value-- ${env.JOB_NAME}"
                    // sh 'echo $'
                    sh 'echo show bash variable value \$MY_VARIABLE'
                    sh 'docker ps'
                }
            }
        }
        stage('Cleaning'){
            steps {
                script {
                    sh './odoo-docker/scripts/cleaning.sh'
                }
            }
        }
    }
}