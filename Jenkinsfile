node {

  checkout scm

  stage('Prepare') {
    sh './pipeline-scripts/prepare.sh'
    echo "${STAGING_SERVER_HOST}"
    echo "${STAGING_SERVER_USER}"
  }

  // stage('Build') {
  //   try {
  //     sh './pipeline-scripts/build.sh'
  //   } catch (exc) {
  //     echo "Something went wrong, cleaning and stop this pipeline!"
  //     sh './pipeline-scripts/clean.sh'
  //     sh 'exit 1'
  //   }
  // }
  // stage('Test #1 (Sonarqube)') {
  //   withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
  //     env.sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
  //     sh './pipeline-scripts/sonarqube.sh > /dev/null 2>&1'
  //   }
  // }

  // stage('Test #2 (Odoo Test cases)') {
  //   withCredentials([string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'),
  //     string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')
  //   ]) {
  //     sh './pipeline-scripts/unit-test.sh'
  //   }
  // }

  // stage('Deploy') {
  //   def remote_server = [:]
  //   remote_server.name = 'Staging server'
  //   remote_server.host = ''
  //   remote_server.user = ''
  //   remote_server.allowAnyHosts = true
  //   withCredentials([])
  // }

  // stage('Clean Test Resources') {
  //   sh './pipeline-scripts/clean.sh'
  // }

}