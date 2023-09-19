node {

    checkout scm

    env.sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'

    // stage ('Prepare') {
    //     sh './pipeline-scripts/prepare.sh'
    // }

    // stage ('Build') {
    //     try {
    //         sh './pipeline-scripts/build.sh'
    //     }
    //     catch (exc) {
    //         sh "echo Something went wrong, cleaning and stop this pipeline!"
    //         sh './pipeline-scripts/clean.sh'
    //         sh 'exit 1'    
    //     }
    // }

    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
        stage ('Test #1 (Sonarqube)') {
            // def sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
            sh './pipeline-scripts/sonarqube.sh'
        }
    }
    

    // withCredentials([string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'), 
    //                  string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')]) {
    //     stage ('Test #2 (Odoo Test cases)') {
    //         sh './pipeline-scripts/unit-test.sh'
    //     }
    // }



    stage ('Clean') {
        sh './pipeline-scripts/clean.sh'
    }
}
