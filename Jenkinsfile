node {

  // checkout scm

  // stage('Prepare') {
  //   sh './pipeline-scripts/prepare.sh'
  //   echo "${STAGING_SERVER_HOST}"
  //   echo "${STAGING_SERVER_USER}"
  // }

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

  
    withCredentials([sshUserPrivateKey(credentialsId: 'staging-server-credentail', keyFileVariable: 'STAGING_SERVER_PRIVATE_KEY', passphraseVariable: '', usernameVariable: 'STAGING_SERVER_USERNAME')]) {
      def remote = [:]
      remote.name = "staging-server"
      remote.host = "13.250.6.26"
      remote.user = "ubuntu"
      remote.identityFile = STAGING_SERVER_PRIVATE_KEY
      remote.allowAnyHosts = true
      
      sh "cat ${STAGING_SERVER_PRIVATE_KEY}"
      // sh "ssh root@103.229.42.127 -i ${STAGING_SERVER_PRIVATE_KEY}"
      stage('Deploy') {
        sshCommand remote: remote, command: 'ls  /opt'
      }
      
    }
  

  // stage('Clean Test Resources') {
  //   sh './pipeline-scripts/clean.sh'
  // }

}
