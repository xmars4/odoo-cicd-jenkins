pipeline {
    agent any

    environment {
        MY_VARIABLE = 'Hello, World!'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
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
                echo 'Deploying...'
                sh 'echo Yeahhhh.aa, current build value \$currentBuild.completeBuild ..'
                sh 'another variable \$MY_VARIABLE'
            }
        }
    }
}