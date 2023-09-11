node {

    checkout scm

    stage ('Prepare'){
        sh './odoo-docker/scripts/prepare.sh'
    }

    stage ('Build') {
        docker.image('postgres:15').withRun('-e "POSTGRES_PASSWORD=odoo" -e "POSTGRES_USER=odoo" -e "POSTGRES_DB=postgres"'){c ->
            docker.image('postgres:15').inside{
                sh 'ls -lah /'
                sh 'echo $POSTGRES_DB $POSTGRES_PASSWORD'
                sh 'psql'
            }
                        // sh 'cat /etc/postgresql/postgresql.conf '
            
        }
    }
}
