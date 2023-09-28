node {

  checkout scm

  // stage('Prepare') {
  //   sh './pipeline-scripts/prepare.sh'
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

  stage('Deploy to server') {
    withCredentials([
      sshUserPrivateKey(credentialsId: 'server-credentail',
        keyFileVariable: 'server_privatekey',
        passphraseVariable: '',
        usernameVariable: 'server_username'),
      file(credentialsId: 'server-github-privatekey',
        variable: 'server_github_privatekey_file')
    ]) {
      // can't use SSH Pipeline Steps yet because it has a bug related to ssh private key authentication
      // ref: https://issues.jenkins.io/browse/JENKINS-65533
      // ref: https://github.com/jenkinsci/ssh-steps-plugin/pull/91
      // so we'll execute ssh manually
      sh './pipeline-scripts/deploy.sh'
      setBuildStatus ("ez", 'Checking out completed', 'SUCCESS')
    }
  }

  // stage('Clean Test Resources') {
  //   sh './pipeline-scripts/clean.sh'
  // }
 
}

// reference: https://gist.github.com/jonico/e205b16cf07451b2f475543cf1541e70
// https://www.jenkins.io/doc/pipeline/steps/github/#stepclass-githubcommitstatussetter-set-github-commit-status-universal
void setBuildStatus(context, message, state) {
  step([
      $class: "GitHubCommitStatusSetter",
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: context],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      // reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://octodemo.com/${getRepoSlug()}"],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

def getRepoSlug() {
    tokens = "${env.JOB_NAME}".tokenize('/')
    org = tokens[tokens.size()-3]
    repo = tokens[tokens.size()-2]
    return "${org}/${repo}"
}