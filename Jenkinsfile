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
            + ' -u root' + ' -v ./odoo-docker/etc/:/etc/odoo'
            ){z ->
                sh "echo ${WORKSPACE}"
                sh "docker ps "
                sh "docker exec ${z.id} sh -c 'ls /etc/odoo && ls /var/log/odoo'"
                sh "docker logs ${z.id}"
                // sh 'ls -lah /var/log/odoo'
                // sh 'pwd'
                // sh 'echo $USER && cat /etc/group'
                // sh 'ls -lah /etc/odoo'
            
            }

        }
        
    }
}
