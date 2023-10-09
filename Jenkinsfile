// By default, before pipeline start, 
// Jenkins will checkout repo with branch specified in 'Branches to build' to get the Jenkinsfile
// so we can't ignore check out default
// Instead, we will perform second checkout with specific branch  (from pull request)
node {
    // withCredentials([string(credentialsId: 'github-webhook-secret-token', variable: 'webhookToken')]) {
    //     properties([
    //         pipelineTriggers([
    //             [
    //                 $class: 'GenericTrigger',
    //                 genericVariables: [
    //                     [key: 'action', value: '$.action', expressionType: 'JSONPath'],
    //                     [key: 'pr_id', value: '$.number', expressionType: 'JSONPath'],
    //                     [key: 'pr_state', value: '$.pull_request.state', expressionType: 'JSONPath'],
    //                     [key: 'pr_merged', value: '$.pull_request.merged', expressionType: 'JSONPath'],
    //                     [key: 'pr_to_ref', value: '$.pull_request.base.ref', expressionType: 'JSONPath'],
    //                     [key: 'pr_to_repo_ssh_url', value: '$.pull_request.base.repo.ssh_url', expressionType: 'JSONPath'],
    //                     [key: 'pr_url', value: '$.pull_request.html_url'],
    //                     [key: 'draft_pr', value: '$.pull_request.draft'],
    //                 ],
    //                 causeString: 'Triggered from PR: $pr_url',
    //                 token: webhookToken,
    //                 regexpFilterText: '$action#$draft_pr',
    //                 regexpFilterExpression: '(reopened|opened|synchronize|ready_for_review)#(false)|(closed)#(true)',
    //                 printContributedVariables: false,
    //                 printPostContent: false,
    //             ]
    //         ])
    //     ])
    // }

    stage('Prepare') {
        if (pr_state != 'closed') {
            // TODO: do we need a different test process when code was merged to main repo 
            git_checkout_pull_request_branch()
        }
        else {
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

    // TODO: if pull request is merge, after test success, we'll deploy it to remote server.
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