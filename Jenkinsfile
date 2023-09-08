node {
    stage('Build') {
        step([$class: 'DockerComposeBuilder', dockerComposeFile: 'odoo-docker/docker-compose.yml', option: [$class: 'StartAllServices'], useCustomDockerComposeFile: true])
    }
    stage('Test') {
        echo 'Testing....'
    }
    stage('Deploy') {
        echo 'Deploying....'
    }
}
