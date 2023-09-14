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


    // def postgres_image = docker.image('postgres:15')
    // // make sure postgres and odoo base image is always the latest
    // postgres_image.pull();
    // docker.image('odoo:16').pull() 

    // stage ('Build') {
    //     postgres_image.withRun('-e "POSTGRES_PASSWORD=odoo"'
    //     + ' -e "POSTGRES_USER=odoo"' 
    //     + ' -e "POSTGRES_DB=postgres"'
    //     + ' --network odoo-cicd-net' 
    //     + ' -p 15430:5432'
    //     + ' --name postgres-db'){c ->
    //         sh './odoo-docker/scripts/build.sh'
    //         sh "docker logs  ${c.id}"
            
    //         docker.image('odoo:16').withRun('-e "HOST=postgres-db"'
    //         + ' -e "PORT=5432"' 
    //         + ' -e "USER=odoo"'
    //         + ' -e "PASSWORD=odoo"'
    //         + ' --network odoo-cicd-net'
    //         + ' -u root' 
    //         + ' -v ${WORKSPACE}/odoo-docker/etc:/etc/odoo'
    //         ){z ->
    //             sh "sleep 30"
    //             sh "docker logs ${z.id}"
    //             sh "docker exec ${z.id} sh -c 'cat /etc/odoo/odoo.conf'"
    //             sh "docker exec ${z.id} sh -c 'cat /var/log/odoo/odoo.log'"
    //         }

    //     }
        
    // }
}
