node {

  checkout scm

    stage('Prepare') {
      sh './pipeline-scripts/prepare.sh'
    }

    stage('Build') {
      try {
        sh './pipeline-scripts/build.sh'
      } catch (exc) {
        sh "echo Something went wrong, cleaning and stop this pipeline!"
        sh './pipeline-scripts/clean.sh'
        sh 'exit 1'
      }
    } 
    stage('Test #1 (Sonarqube)') {
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
          env.sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'      
          sh './pipeline-scripts/sonarqube.sh > /dev/null 2>&1'
          sh 'echo "something here ..."'
        }
    }
  
    stage('Test #2 (Odoo Test cases)') {
          withCredentials([string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'),
                           string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')
        ]) {
            sh './pipeline-scripts/unit-test.sh'
        }
    }



    stage('Clean Test Resources') {
      sh './pipeline-scripts/clean.sh'
    }
    
}