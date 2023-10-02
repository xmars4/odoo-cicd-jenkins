# Setup

1.  Install Jenkins - using docker

    1.1. Execute bash script to create Jenkins data folder

    ```shell
        sudo ./jenkins-docker-compose/host-setup.sh
    ```

    1.2. Run Jenkins

    ```shell
        cd jenkins-docker-compose
        docker compose up -d --build
    ```

2.  Allow Jenkins connect to Github using SSH keys

    2.1. Access (SSH) to Jenkins instance

    -   [Generate SSH keys or find existing keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

    -   [Add SSH keys to ssh-agent](https://www.jenkins.io/doc/book/installing/)

    2.2. Create a **SSH Username with private key** credential in Jenkins

    -   Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted)
    -   Kind: SSH Username with private key
    -   Username: your github username
    -   Private key / Enter directly: paste your private SSH key at step **2.1** here

    2.3. [Add SSH public key (.pub) at step **2.1.**to Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

3.  Config Github plugin - allow trigger job in Jenkins by Github webhook

    3.1. [Generate Github fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with following scopes:

    -   **Repository access / Only select repositories**: select repo that the Jenkins instance will connect to
    -   **Permissions**:
        -   **Webhooks**: Access: Read and write
        -   **Commit statuses**: Access: Read and write

    <end-list></end-list>

    3.2. Create a **Secret Text** credential in Jenkins

    -   Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted)
    -   Paste your access token generated from step **3.1** to **Secret** box

    3.3. Config Github Server

    -   Path: Dashboard > Manage Jenkins > System : Github / Github Servers
    -   Add new Github server with following information:
        -   API URL: https://api.github.com
        -   Credentials: select the credential created at step **3.2**
        -   Click _Test connection_ to check your configuration
    -   Click Save

4.  [Create Github webhook](https://docs.github.com/en/webhooks/using-webhooks)

    4.1. If you use a local server to receive webhook, [reference this guide](https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks#exposing-localhost-to-the-internet) to expose localhost to internet

    4.2. Add Jenkins's hook url to repo's webhook

    -   Open Github repo page
    -   Path: Settings / Webhooks / Add webhook
    -   Payload URL (the ending forward slash **/** is important): <public_jenkins_url>/github-webhook/
    -   Content type: application/json
    -   Which events would you like to trigger this webhook? : select which events do you want to receive hook request
    -   Click : Add webhook

5.  Config remote server info

    5.1. Add server ssh credential in Jenkins

    -   Jenkins will use this credential to connect to the server and execute commands, scripts.
    -   Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted)
    -   **Kind**: SSH Username with private key
    -   **ID**: _server-credentail_ - this value mapped with Jenkinsfile, so if you want to change, you also need to change it Jenkinsfile
    -   **Username**: the server's username
    -   **Private Key / Enter directly / Key / Add**: the private key use to access the server

    5.2. Allow remote server connect to Github using SSH keys

    5.2.1. Access (SSH) to server

    -   [Generate SSH keys or find existing keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

    -   [Add SSH keys to ssh-agent](https://www.jenkins.io/doc/book/installing/)

    5.2.2. [Add SSH public key (.pub) at step **5.2.1** to Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

    5.3. Add github private key credentail in Jenkins

    -   Server will use this private key to connect to Github and pull latest code
    -   Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted)
    -   **Kind**: Secret file
    -   **File**: Upload the ssh private key generated at step **5.2.1**
    -   **ID**: _server-github-privatekey_

6.  Create and config Github pipeline

    6.1. Create new pipeline

    -   Path: Dashboard > New Item -> Pipeline
    -   Fill pipeline name. _warning_ [don't put space to pipeline name](https://www.jenkins.io/doc/book/pipeline/getting-started/#:~:text=In%20the%20Enter%20an%20item,handle%20spaces%20in%20directory%20paths.)
    -   Select option **GitHub hook trigger for GITScm polling**
    -   Pipeline / Definition, select **Pipeline script from SCM**
    -   SCM: Git
    -   Repositories / Repository URL: paste your **SSH** repo url that contains Jenkinsfile and webhook here. e.g: git@github.com:xmars4/odoo-cicd-jenkins.git
    -   Credentials: select the credential you created at step **2.4**
    -   Branches to build / Branch Specifier: select apropriate branch

    6.2. Add remote server information

    -   Jenkins will use these variable for CD process (deploy to remote server)
    -   Continuing update the pipeline in step **4.1**
    -   Select **Prepare an environment for the run**
    -   Select **Keep Jenkins Environment Variables**
    -   Select **Keep Jenkins Build Variables**
    -   Properties Content: add below variables with appropriate value

        ```
        server_host=<server ip address here>
        server_docker_compose_path=<path to folder contain odoo docker-compose.yml file>
        server_config_file=<path to odoo config file>
        server_extra_addons_path=<path to custom addons folder, also a git repo>
        ```

        for example:

        ```
        server_host=12.34.56.78
        server_docker_compose_path=/opt/odoo/
        server_config_file=/opt/odoo/odoo.conf
        server_extra_addons_path=/opt/odoo/extra_addons
        ```

7.  Integration with SonarQube

    7.1. Install SonarQube

    -   Install SonarQube and allow Jenkins to connect to it (already done in docker compose file)
    -   Access SonarQube instance and [generate a user token](https://docs.sonarsource.com/sonarqube/latest/user-guide/user-account/generating-and-using-tokens/#generating-a-token)

    7.2. Add SonarQube installer to Jenkins

    -   Path: Dasboard / Manage Jenkins / Tools / SonarQube Scanner
    -   Click _Add SonarQube Scanner_
        -   Input Name: **sonarqube-scanner**
        -   Check: **Install automatically**

    7.3. Add SonarQube credentail to Jenkins

    -   Add a secret text credentail to your Jenkins instance
        -   **ID**: sonar-token **Secret**: the token was obtained from step 6.1

8.  Send message to Telegram from Jenkins

    -   Follow [this link](https://gist.github.com/xmars4/25931e4e59476da70a183d0f5a1d9e9e) to obtain **BOT token** and **Channel ID**
    -   Add two secret text credentails to your Jenkins instance
        -   **ID**: telegram-bot-token **Secret**: BOT token
        -   **ID**: telegram-channel-id **Secret**: Channel ID

9.  Trigger build process manually

    -   **You have to trigger build process first time manually before Github webhook can trigger the build process automatically**

    -   Path: Dashboard / Your pipeline / Build Now

:zap::zap:**Congrats**:v::v: : now your pipeline will automatic start building when the repo received a push event

# Reference

-   ![Flow](img/CI-CD-flow.png)

-   Run Jenkins from [docker-compose.yml](jenkins-docker-compose/docker-compose.yml) file using a **[bind mount](https://github.com/jenkinsci/docker/blob/master/README.md#usage)** volume:

    ```bash
    touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
    Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?
    ```

    -> Solution:

    ```bash
    $ sudo mkdir -p /var/jenkins_home && sudo chown -R 1000:1000 /var/jenkins_home/
    ```

-   [Why use bind mount volume instead of volume for Jenkins' container](https://stackoverflow.com/questions/62678663/jenkins-in-docker-clarification-about-bind-mounts-in-pipelines/62679925#62679925)

-   [SonarQube](https://docs.sonarsource.com/sonarqube/latest/) code quality inspection -> use to scan Odoo addons

-   [wait-for-it.sh bash script](https://github.com/vishnubob/wait-for-it)
-   [Manage java versions on controller and nodes
    ](https://www.youtube.com/watch?v=ZabUz6sl-8I)

-   [Binding credentails to variable](https://www.jenkins.io/doc/pipeline/steps/credentials-binding/)
-   permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock -> check Jenkins Dockerfile , line 17,18
    to create a new group mapped with docker group on host
