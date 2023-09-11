node {
    // stage ('Prepare'){
    //     sh './odoo-docker/scripts/prepare.sh'
    // }

    stage ('Build') {
        docker.image('postgres:15').withRun('-e "POSTGRES_PASSWORD=odoo" -e "POSTGRES_USER=odoo" -e "POSTGRES_DB=postgres" ) {
            // sh 'cat /etc/postgresql/postgresql.conf '
            sh 'ls -lah /'
        }
    }
}
