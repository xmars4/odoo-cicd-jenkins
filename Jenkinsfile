node {
  stage('Prepare') {
    git_checkout()
    verify_tools()
    setup_environment_variables()
    clean_test_resource() // in case previous job can't clean
  }

  stage('Build') {
    build()
  }

  // stage('Test #1 (Sonarqube)') {
  //     sonarqube_check_code_quality()
  // }

  stage('Test #2 (Odoo Test cases)') {
    unit_test()
  }

//   stage('Deploy to server') {
//     deploy_to_server()
//   }
//
//   stage('Clean Test Resources') {
//     clean_test_resource()
//   }

}

def setup_environment_variables() {
  env.ODOO_IMAGE_TAG = "xmars/odoo16-cicd"
  env.ODOO_WORKSPACE = "${env.WORKSPACE}/odoo-docker-compose"
  env.ODOO_ADDONS_PATH = "${ODOO_WORKSPACE}/extra-addons"
  env.CONFIG_FILE = "${ODOO_WORKSPACE}/etc/odoo.conf"
  env.LOG_FILE = "/var/log/odoo/odoo.log" // file log is inside the odoo container
  env.LOG_FILE_OUTSIDE = "${ODOO_WORKSPACE}/logs/odoo.log" // file log is outside the odoo container (copied from odoo container)
}

def git_checkout() {
  if (pr_state != 'closed') {
    // TODO: do we need a different test process when code was merged to main repo 
    git_checkout_pull_request_branch()
  } else {
    git_checkout_main_branch()
  }
}

def git_checkout_main_branch() {
  // the branch that pull request is merge 'TO'
  echo "Checkout main branch!"
  checkout scmGit(branches: [
      [name: "origin/${pr_to_ref}"]
    ],
    extensions: [
      cloneOption(honorRefspec: true),
    ],
    userRemoteConfigs: [
      [credentialsId: 'github-ssh-cred', name: 'origin',
        refspec: '+refs/heads/*:refs/remotes/origin/*',
        url: "${pr_to_repo_ssh_url}"
      ]
    ])
}

def git_checkout_pull_request_branch() {
  // the branch that pull request is merge 'FROM'
  echo "Checkout pull request branch!"
  checkout scmGit(branches: [
      [name: "origin/pr/${pr_id}"]
    ],
    extensions: [
      cloneOption(honorRefspec: true),
    ],
    userRemoteConfigs: [
      [credentialsId: 'github-ssh-cred', name: 'origin',
        refspec: '+refs/pull/*/head:refs/remotes/origin/pr/* +refs/heads/*:refs/remotes/origin/*',
        url: "${pr_to_repo_ssh_url}"
      ]
    ])
}

def verify_tools() {
  def result = sh(script: './pipeline-scripts/verify.sh > /dev/null', returnStatus: true)
  if (result != 0) {
    // missing required tools, stop pipeline immediately
    sh "exit $result"
  }
}

def build() {
  def result = sh(script: './pipeline-scripts/build.sh', returnStatus: true)
  if (result != 0) {
//     clean_test_resource()
    sh "exit $result"
  }
}

def sonarqube_check_code_quality() {
  withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
    env.sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    sh './pipeline-scripts/sonarqube.sh > /dev/null 2>&1'
  }
}

def unit_test() {

  def result = sh(script: './pipeline-scripts/unit-test.sh', returnStatus: true)
  echo "what the hell is result $result"
  if (result != 0) {
    set_github_commit_status("failure", "The build failed, please re-check the code!");
    send_telegram_file(LOG_FILE_OUTSIDE, "The [pull request ${pr_id}](${pr_url}) checking has failed, please check the log file!")
//     clean_test_resource()
    sh "exit $result"
  }
  set_github_commit_status("success", "The build succeed!");
}

def deploy_to_server() {
  if (pr_state == 'merged') {
    withCredentials([
      sshUserPrivateKey(credentialsId: 'remote-server-cred',
        keyFileVariable: 'server_privatekey',
        passphraseVariable: '',
        usernameVariable: 'server_username'),
      file(credentialsId: 'remote-server-github-privatekey-cred',
        variable: 'server_github_privatekey_file')
    ]) {
      // can't use SSH Pipeline Steps yet because it has a bug related to ssh private key authentication
      // ref: https://issues.jenkins.io/browse/JENKINS-65533
      // ref: https://github.com/jenkinsci/ssh-steps-plugin/pull/91
      // so we'll execute ssh manually
      sh './pipeline-scripts/deploy.sh'
    }
  }
}

def clean_test_resource() {
  sh './pipeline-scripts/clean.sh'
}

def set_github_commit_status(String state, String message) {
  withCredentials([
    string(credentialsId: 'github-access-token-cred', variable: 'github_access_token')
  ]) {
    sh "./pipeline-scripts/utils.sh set_github_commit_status_default '${state}' '${message}'"
  }
}

def send_telegram_file(String file_path, String message) {
  withCredentials([
    string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'),
    string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')
  ]) {
    sh "./pipeline-scripts/utils.sh send_file_telegram_default '${file_path}' '${message}'"
  }
}
def send_telegram_message() {
  withCredentials([
    string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'),
    string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')
  ]) {}
}