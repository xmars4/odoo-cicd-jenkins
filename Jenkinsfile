node {

    checkout scm

    stage ('Verify tooling') {
        sh './pipeline-scripts/build.sh'
    }

    stage ('Build') {
        sh './pipeline-scripts/build.sh'
    }

    stage ('Test') {
        sh './pipeline-scripts/test.sh'
    }

    stage ('Clean') {
        sh './pipeline-scripts/clean.sh'
    }
}
