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

  
    withCredentials([sshUserPrivateKey(credentialsId: 'staging-server-credentail', 
    keyFileVariable: 'server_privatekey', 
    passphraseVariable: '', 
    usernameVariable: 'server_username')]) {
      // can't use SSH Pipeline Steps yet because it has a bug related to ssh
      // ref: https://issues.jenkins.io/browse/JENKINS-65533
      // ref: https://github.com/jenkinsci/ssh-steps-plugin/pull/91
      // so we execute ssh manually
      def remote = [:]
      remote.name = 'test'
      remote.host = STAGING_SERVER_HOST
      remote.user = STAGING_SERVER_USER
      // remote.password = PASSW
      remote.indentityFile = server_privatekey
      remote.allowAnyHosts = true
      // sh "cat ${STAGING_SERVER_PRIVATE_KEY}"
      // sh "ssh ${STAGING_SERVER_USERNAME}@${STAGING_SERVER_HOST} -i ${STAGING_SERVER_PRIVATE_KEY} 'ls '"
      stage('Deploy') {
        sshCommand remote: remote, command: 'ls -la /opt'
      }
    }

  // stage('Clean Test Resources') {
  //   sh './pipeline-scripts/clean.sh'
  // }

}
