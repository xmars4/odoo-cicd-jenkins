pipeline {
    agent any

    environment {
        MY_VARIABLE = 'Hello, World!'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    sh "cd odoo-docker"
                    sh "ls -lah"
                    sh "docker compose up -d"
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
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
    }
}