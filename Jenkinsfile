
node {
    stage('Prepare') {
        if (pr_state != 'closed') {
            // TODO: do we need a different test process when code was merged to main repo 
            echo "Checkout pull request branch!s"
            git_checkout_pull_request_branch()
        }
        else {
            echo "Checkout main branch!"
            git_checkout_main_branch()
        }
        verify_tools()
        setup_environment_variables()
        
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

    stage('Deploy to server') {
        if (pr_state == 'merged'){
            deploy_to_server()
        }
    }

    stage('Clean Test Resources') {
        clean_test_resource()
    }

}

def setup_environment_variables() {
    env.ODOO_IMAGE_TAG = "xmars/odoo16-cicd"
    env.ODOO_WORKSPACE = "${env.WORKSPACE}/odoo-docker-compose"
    env.ODOO_ADDONS_PATH = "${ODOO_WORKSPACE}/extra-addons"
    env.CONFIG_FILE = "${ODOO_WORKSPACE}/etc/odoo.conf"
    env.LOG_FILE = "/var/log/odoo/odoo.log" // file log is inside the odoo container
}

def git_checkout_main_branch() {
    // the branch that pull request is merge 'TO'
    checkout scmGit(branches: [
    [name: "origin/${pr_to_ref}"]
    ], 
    extensions: [
        cloneOption(honorRefspec: true), 
    ],
     userRemoteConfigs: [
    [credentialsId: 'github-ssh-sotatek', name: 'origin', 
    refspec: '+refs/heads/*:refs/remotes/origin/*', 
    url: "${pr_to_repo_ssh_url}"]
    ])
}

def git_checkout_pull_request_branch() {
    // the branch that pull request is merge 'FROM'
    checkout scmGit(branches: [
    [name: "origin/pr/${pr_id}"]
    ], 
    extensions: [
        cloneOption(honorRefspec: true), 
    ],
     userRemoteConfigs: [
    [credentialsId: 'github-ssh-sotatek', name: 'origin', 
    refspec: '+refs/pull/*/head:refs/remotes/origin/pr/* +refs/heads/*:refs/remotes/origin/*', 
    url: "${pr_to_repo_ssh_url}"]
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
        clean_test_resource()
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
    withCredentials([
        string(credentialsId: 'telegram-bot-token', variable: 'TELEGRAM_BOT_TOKEN'),
        string(credentialsId: 'telegram-channel-id', variable: 'TELEGRAM_CHANNEL_ID')
    ]) {
        try {
            sh './pipeline-scripts/unit-test.sh'
            set_github_commit_status("success", "The build succeed!");
        } catch (e) {
            set_github_commit_status("failure", "The build failed, please re-check the code!");
            sh 'exit 1'
        }
    }
}

def deploy_to_server() {
    withCredentials([
        sshUserPrivateKey(credentialsId: 'remote-server-credentail',
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
    }
}

def clean_test_resource() {
    sh './pipeline-scripts/clean.sh'
}

def set_github_commit_status(String state, String message) {
    withCredentials([
        string(credentialsId: 'github-access-token', variable: 'github_access_token')
        ]){
            sh "./pipeline-scripts/utils.sh set_github_commit_status_default '${state}' '${message}'"
        }
}
