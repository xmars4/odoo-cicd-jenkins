node {

    checkout scm

    stage ('Prepare'){
        sh './odoo-docker/scripts/prepare.sh'
    }

    stage ('Build') {
        docker.image('postgres:15').withRun('-e "POSTGRES_PASSWORD=odoo"'
        + ' -e "POSTGRES_USER=odoo"' 
        + ' -e "POSTGRES_DB=postgres"'
        + ' --network odoo-cicd-net' 
        + ' -p 15430:5432'){c ->

            
        }
    }
}
