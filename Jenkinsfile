node {
    stage('Prepare') {
        git_checkout()
        setup_environment_variables()
        verify_tools()
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

    stage('Deploy to server') {
        deploy_to_server()
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
    env.LOG_FILE = "/var/log/odoo/odoo.log" // the log file is inside the odoo container
    env.LOG_FILE_OUTSIDE = "${ODOO_WORKSPACE}/logs/odoo.log" // mounted odoo's log file in Jenkins instance
    env.PIPELINE_SCRIPTS_PATH = "${env.WORKSPACE}/pipeline-scripts"
}

def git_checkout() {
    if (pr_state != 'closed') {
        // TODO: do we need a different test process when code was merged to main repo 
        // like running test cases on existing database instead of empty database
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
    def result = sh(script: "$PIPELINE_SCRIPTS_PATH/verify.sh > /dev/null", returnStatus: true)
    if (result != 0) {
        // missing required tools, stop pipeline immediately
        sh "exit $result"
    }
}

def build() {
    def result = sh(script: "$PIPELINE_SCRIPTS_PATH/build.sh", returnStatus: true)
    if (result != 0) {
        clean_test_resource()
        sh "exit $result"
    }
}

def sonarqube_check_code_quality() {
    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
        env.sonarqubeScannerHome = tool name: 'sonarqube-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
        sh "$PIPELINE_SCRIPTS_PATH/sonarqube.sh > /dev/null 2>&1"
    }
}

def unit_test() {

    def result = sh(script: "$PIPELINE_SCRIPTS_PATH/unit-test.sh", returnStatus: true)
    if (result != 0) {
        def git_commit_message = "The build failed, please re-check the code!"
        set_github_commit_status("failure", git_commit_message);

        def telegram_message = "The [PR \\#${pr_id}](${pr_url}) check has failed\\.\\n Please take a look at the attached log file 🔬"
        send_telegram_file(LOG_FILE_OUTSIDE, telegram_message)

        clean_test_resource()
        sh "exit $result"
    }
    set_github_commit_status("success", "The build succeed!");
}

def deploy_to_server() {
    // if (pr_state == 'closed' && pr_merged == 'true') {
        withCredentials([
            sshUserPrivateKey(credentialsId: 'remote-server-cred',
                keyFileVariable: 'server_privatekey',
                passphraseVariable: '',
                usernameVariable: 'server_username'),
            file(credentialsId: 'remote-server-github-privatekey-cred',
                variable: 'server_github_privatekey_file')
        ]) {
            // FIXME: move remote command to ssh-step-plugins
            // https://plugins.jenkins.io/ssh-steps/
            def remote = [:]
            remote.name = "node-1"
            remote.host = "103.229.42.127"
            remote.allowAnyHosts = true
            remote.user = server_username
            remote.identityFile = server_privatekey
            remote.fileTransfer = "scp"
            
            def git_private_key_folder_in_server = "~/.ssh/cicd"
            def git_private_key_file_in_server="$git_private_key_folder_in_server/odoo-cicd-git-privkey"
            def server_deploy_script="/tmp/odoo-cicd-deploy.sh"
            // try {
                sshCommand remote:remote, command: "[ ! -d $git_private_key_folder_in_server ] && mkdir -p $git_private_key_folder_in_server || true"
                sshPut remote: remote, from: server_github_privatekey_file, into: git_private_key_file_in_server
                sshPut remote: remote, from: "$PIPELINE_SCRIPTS_PATH/server_deploy.sh", into: server_deploy_script
                sshCommand remote: remote, command: "$server_deploy_script '$server_docker_compose_path' '$server_extra_addons_path' '$server_config_file' '$git_private_key_file_in_server'"
                def success_message = "The [PR \\#${pr_id}](${pr_url}) was merged and deployed to server 💫🤩💫"
                send_telegram_message(success_message)
            // }
            // catch (Exception e){
                def failed_message = "The [PR \\#${pr_id}](${pr_url}) was merged but the deployment to the server failed.Please take a look into the server."
                send_telegram_message(failed_message)
            // }
            

            // def result = sh(script: './pipeline-scripts/deploy.sh', returnStatus: true)
            // if (result == 0) {
            //     def message = "The [PR \\#${pr_id}](${pr_url}) was merged and deployed to server 💫🤩💫"
            //     send_telegram_message(message)
            // }
        // }
    }
}

def clean_test_resource() {
    sh './pipeline-scripts/clean.sh'
}

def set_github_commit_status(String state, String message) {
    withCredentials([
        string(credentialsId: 'github-access-token-cred', variable: 'github_access_token')
    ]) {
        result = sh(script: "$PIPELINE_SCRIPTS_PATH/utils.sh set_github_commit_status_default '${state}' '${message}'", returnStdout: true).trim()
        if (result) {
            echo "$result"
        }
    }
}

def send_telegram_file(String file_path, String message) {
    withCredentials([
        string(credentialsId: 'telegram-bot-token', variable: 'telegram_bot_token'),
        string(credentialsId: 'telegram-channel-id', variable: 'telegram_channel_id')
    ]) {
        result = sh(script: "$PIPELINE_SCRIPTS_PATH/utils.sh send_file_telegram_default '${file_path}' '${message}'", returnStdout: true).trim()
        if (result) {
            echo "$result"
        }
    }
}

def send_telegram_message(String message) {
    withCredentials([
        string(credentialsId: 'telegram-bot-token', variable: 'telegram_bot_token'),
        string(credentialsId: 'telegram-channel-id', variable: 'telegram_channel_id')
    ]) {
        result = sh(script: "$PIPELINE_SCRIPTS_PATH/utils.sh send_message_telegram_default '${message}'", returnStdout: true).trim()
        if (result) {
            echo "$result"
        }
    }
}