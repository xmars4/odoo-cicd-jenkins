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

  
    stage('Deploy to server') {
      withCredentials([sshUserPrivateKey(credentialsId: 'staging-server-credentail', 
    keyFileVariable: 'server_privatekey', 
    passphraseVariable: '', 
    usernameVariable: 'server_username')]) {
      // can't use SSH Pipeline Steps yet because it has a bug related to ssh private key authentication
      // ref: https://issues.jenkins.io/browse/JENKINS-65533
      // ref: https://github.com/jenkinsci/ssh-steps-plugin/pull/91
      // so we'll execute ssh manually
      sh './pipeline-scripts/deploy.sh'
     }
    }

  // stage('Clean Test Resources') {
  //   sh './pipeline-scripts/clean.sh'
  // }
  
}
