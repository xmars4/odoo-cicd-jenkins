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
            
            docker.image('odoo:16').withRun('-e "HOST=postgres-db"'
            + ' -e "PORT=5432"' 
            + ' -e "USER=odoo"'
            + ' -e "PASSWORD=odoo"'
            + ' --network odoo-cicd-net'
            + ' -u root' 
            + ' -v ${WORKSPACE}/odoo-docker/etc:/etc/odoo'
            + ' -- -i sale_stock'
            ){z ->
                sh "sleep 30"
                sh "docker logs ${z.id}"
                sh "docker exec ${z.id} sh -c 'cat /etc/odoo/odoo.conf'"
                sh "docker exec ${z.id} sh -c 'cat /var/log/odoo/odoo.log'"
            }

        }
        
    }
}
