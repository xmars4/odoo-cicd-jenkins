node {

    setup_global_variables()
    git_checkout()

    stage('Prepare') {
        verify_tools()
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





def setup_global_variables() {
    def workspace = env.WORKSPACE;
    def odoo_image_tag="xmars/odoo16-cicd"
    def odoo_workspace = "${workspace}/odoo-docker-compose"
    def odoo_addons_path= "${odoo_workspace}/extra-addons"
    def CONFIG_FILE="${odoo_workspace}/etc/odoo.conf"
    def LOG_FILE="/var/log/odoo/odoo.log" // file log is inside the odoo container
}

def git_checkout(){
    checkout scm
}

def verify_tools() {
    sh './pipeline-scripts/verify.sh'
}

def build() {
    try {
        sh './pipeline-scripts/build.sh'
    } catch (e) {
        echo "$e"
        clean()
        sh 'exit 1'
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
            setBuildStatus("Check complete", "SUCCESS");
        } catch (e) {
            setBuildStatus("Check complete", "FAILED");
            sh 'exit 1'
        }
    }
}

def deploy_to_server() {
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
    }
}

def clean_test_resource() {
    sh './pipeline-scripts/clean.sh'
}

// https://plugins.jenkins.io/github/#plugin-content-pipeline-examples
void setBuildStatus(String message, String state) {
    step([
        $class: "GitHubCommitStatusSetter",
        // reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/xmars4/odoo-cicd-jenkins"],
        contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
        errorHandlers: [
            [$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]
        ],
        statusResultSource: [$class: "ConditionalStatusResultSource", results: [
            [$class: "AnyBuildResult", message: message, state: state]
        ]]
    ]);
}