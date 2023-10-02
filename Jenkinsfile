node {

  

  stage('Prepare') {
    prepare()
    // sh './pipeline-scripts/prepare.sh'
  }

  // stage('Build') {
  //   try {
  //     sh './pipeline-scripts/build.sh'
  //   } catch (e) {
  //     echo "Something went wrong, cleaning and stop this pipeline!"
  //     echo "$e"
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
  //     try {
  //       sh './pipeline-scripts/unit-test.sh'
  //       setBuildStatus("Check complete", "SUCCESS");
  //     } catch (e){
  //       setBuildStatus("Check complete", "FAILED");
  //       sh 'exit 1'
  //     }
  //   }
  // }

  // stage('Deploy to server') {
  //   withCredentials([
  //     sshUserPrivateKey(credentialsId: 'server-credentail',
  //       keyFileVariable: 'server_privatekey',
  //       passphraseVariable: '',
  //       usernameVariable: 'server_username'),
  //     file(credentialsId: 'server-github-privatekey',
  //       variable: 'server_github_privatekey_file')
  //   ]) {
  //     // can't use SSH Pipeline Steps yet because it has a bug related to ssh private key authentication
  //     // ref: https://issues.jenkins.io/browse/JENKINS-65533
  //     // ref: https://github.com/jenkinsci/ssh-steps-plugin/pull/91
  //     // so we'll execute ssh manually

  //     sh './pipeline-scripts/deploy.sh'
      
  //   }
  // }

  // stage('Clean Test Resources') {
  //   sh './pipeline-scripts/clean.sh'
  // }
 
}

// https://plugins.jenkins.io/github/#plugin-content-pipeline-examples
void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      // reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/xmars4/odoo-cicd-jenkins"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

def prepare() {
  checkout scm
  sh './pipeline-scripts/prepare.sh'
}
