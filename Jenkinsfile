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
        + ' -p 15430:5432'
        + ' --name postgres-db'){c ->
            sh './odoo-docker/scripts/build.sh'
            sh "docker logs  ${c.id}"
            
            docker.image('odoo:16').inside('-e "HOST=postgres-db"'
            + ' -e "PORT=5432"' 
            + ' -e "USER=odoo"'
            + ' -e "PASSWORD=odoo"'
            + ' --network odoo-cicd-net'){z ->
                // sh "docker logs ${z.id}"
                sh 'tail /var/log/odoo/odoo.log'
            }

        }
        
    }
}
