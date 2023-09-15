node {

    // clean workspace
    cleanWs()
    checkout scm

    stage ('Prepare') {
        sh './pipeline-scripts/prepare.sh'
    }

    stage ('Build') {
        try {
            sh './pipeline-scripts/build.sh'
        }
        catch (exc) {
            sh "echo Something went wrong, cleaning and stop this pipeline!"
            sh './pipeline-scripts/clean.sh'
            sh 'exit 1'    
        }
    }

    

    withCredentials([string(credentialsId: 'telegram-odoo-cicd-bot-token', variable: 'TELEGRAM_BOT_TOKEN')]) {
        stage ('Test') {
            sh './pipeline-scripts/test.sh'
            sh "echo ${TELEGRAM_BOT_TOKEN}"
        }
    }
    stage ('Clean') {
        sh './pipeline-scripts/clean.sh'
    }
}
