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
                script {
                    echo 'Deploying...'
                    // def build_status = currentBuild.completeBuild
                    sh 'echo Yeahhhh.aa, current build value \$build_status -- \${env.JOB_NAME} ...'
                    sh 'echo show bash variable value \$MY_VARIABLE'
                }
                
            }
        }
    }
}