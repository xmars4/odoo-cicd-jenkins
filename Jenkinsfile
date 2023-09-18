node {

    // clean workspace
    // cleanWs()
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

    

    withCredentials([string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'), 
                     string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')]) {
        stage ('Test') {
            sh './pipeline-scripts/test.sh'
        }
    }
    stage ('Clean') {
        sh './pipeline-scripts/clean.sh'
    }
}
