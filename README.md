# Setup

1.  Install Jenkins and some useful plugins

    1.1. [Install Jenkins](https://www.jenkins.io/doc/book/installing/)

    1.2. [Install Github plugin](https://plugins.jenkins.io/github/)

    1.3. [Install ssh-agent](https://plugins.jenkins.io/ssh-agent/)

2.  Allow Jenkins connect to Github - with SSH key

    2.1. [Generate SSH key or find an existing on Jenkins's host](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

    2.2. [Add SSH key to ssh-agent](https://www.jenkins.io/doc/book/installing/)

    2.3. [Add SSH public key (.pub) to Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

    2.4. Create a **SSH Username with private key** credential in Jenkins

    -   Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted)
    -   Kind: SSH Username with private key
    -   Username: your github username
    -   Private key / Enter directly: paste your private SSH key at step **2.1** here

    2.5. Add github.com to known_hosts file (if you used the Jenkins's Dockerfile in this repo, ignore this step)

    ```bash
    ssh-keyscan github.com >> /var/jenkins_home.ssh/known_hosts
    ```

3.  Config Github plugin - allow trigger job in Jenkins by Github webhook

    3.1. [Generate Github fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with following scopes:

    -   **admin:repo_hook** - for managing hooks (read, write and delete old ones)
    -   **repo** - to see private repos
    -   **repo:status** - to manipulate commit statuses

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

5.  Create and config Github pipeline

    4.1. Create new pipeline

    -   Path: Dashboard > New Item -> Pipeline
    -   Select option **GitHub hook trigger for GITScm polling**
    -   Pipeline / Definition, select **Pipeline script from SCM**
    -   SCM: Git
    -   Repositories / Repository URL: paste your **SSH** repo url that contains Jenkinsfile and webhook here. e.g: git@github.com:xmars4/odoo-cicd-jenkins.git
    -   Credentials: select the credential you created at step **2.4**
    -   Branches to build / Branch Specifier: select a propriate branch

# Reference

-   Run Jenkins from [docker-compose.yml](docker-compose/docker-compose.yml) file and got error

    ```bash
    touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
    Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?
    ```

    -> Solution:

    ```bash
    $ sudo chown -R 1000:1000 docker-compose/var/jenkins_home/
    ```

-   [SonarQube](https://docs.sonarsource.com/sonarqube/latest/) code quality inspection -> use to scan Odoo addons
