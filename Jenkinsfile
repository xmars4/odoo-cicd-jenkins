node {

    checkout scm

    stage ('Verify tooling') {
        sh '''
            docker version
            docker info
            docker compose version
            curl --version
        '''
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
