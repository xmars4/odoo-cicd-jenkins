node {

    withCredentials([string(credentialsId: 'github-webhook-secret-token', variable: 'webhookToken')]) {
        properties([
            pipelineTriggers([
                [
                    $class: 'GenericTrigger',
                    genericVariables: [
                        [key: 'action', value: '$.action', expressionType: 'JSONPath'],
                        [key: 'pr_id', value: '$.pull_request.number', expressionType: 'JSONPath'],
                        [key: 'pr_state', value: '$.pull_request.state', expressionType: 'JSONPath'],
                        [key: 'pr_title', value: '$.pull_request.title', expressionType: 'JSONPath'],
                        [key: 'pr_from_ref', value: '$.pull_request.head.ref', expressionType: 'JSONPath'],
                        [key: 'pr_from_sha', value: '$.pull_request.head.sha', expressionType: 'JSONPath'],
                        [key: 'pr_from_git_url', value: '$.pull_request.head.repo.git_url', expressionType: 'JSONPath'],
                        [key: 'pr_to_ref', value: '$.pull_request.base.ref', expressionType: 'JSONPath'],
                        [key: 'pr_to_sha', value: '$.pull_request.base.sha', expressionType: 'JSONPath'],
                        [key: 'pr_to_git_url', value: '$.pull_request.base.repo.git_url', expressionType: 'JSONPath'],
                        [key: 'repo_git_url', value: '$.repository.git_url', expressionType: 'JSONPath'],
                        [key: 'draft_pr', value: '$.pull_request.draft'],
                    ],
                    causeString: 'Triggered from PR: $pr_url',
                    token: webhookToken,
                    regexpFilterText: '$action#$draft_pr',
                    regexpFilterExpression: '(reopened|opened|synchronize|ready_for_review)#(false)',
                    printContributedVariables: false,
                    printPostContent: false,
                ]
            ])
        ])
    }

    stage('Prepare') {
        // echo "$action =>> yetry harder ah"
            checkout scmGit(
    branches: [[name: 'pr/4/*']],
    extensions: [ cloneOption(honorRefspec: true) ],
    userRemoteConfigs: [[refspec: '+refs/pull/*/head:refs/remotes/origin/pr/*']])
        sh 'ls -lah .'
        // git_checkout()
        // verify_tools()
        // setup_environment_variables()
    }

    // stage('Build') {
    //     build()
    // }

    // stage('Test #1 (Sonarqube)') {
    //     sonarqube_check_code_quality()
    // }

    // stage('Test #2 (Odoo Test cases)') {
    //     unit_test()
    // }

    // TODO: if pull request is merge, after test success, we'll deploy it to remote server...
    // https://github.com/jenkinsci/generic-webhook-trigger-plugin/blob/master/src/test/resources/org/jenkinsci/plugins/gwt/bdd/github/github-pull-request.feature
    // stage('Deploy to server') {
    //     deploy_to_server()
    // }

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

def git_checkout() {
    checkout scm
}

def git_checkout_pull_request() {
    checkout scmGit(
        branches: [[name: "pr/$pr_id"]],
        extensions: [ cloneOption(honorRefspec: true) ],
    )
}

def verify_tools() {
    def result = sh(script: './pipeline-scripts/verify.sh > /dev/null', returnStatus: true)
    if (result != 0) {
        // misisng required tools, stop pipeline immediately 
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
