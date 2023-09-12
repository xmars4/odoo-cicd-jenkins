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
            sh './odoo-docker/scripts/build.sh'
            sh "docker logs ${c.id}"
            docker.image('odoo:16').withRun('-e "HOST=db"'
            + ' -e "PORT=5432"' 
            + ' -e "USER=odoo"'
            + ' -e "PASSWORD=odoo"'){z ->
                sh "docker logs ${c.id}"
            }
        }
        
    }
}
