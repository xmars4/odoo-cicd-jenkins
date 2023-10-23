# Jenkins CI/CD for Odoo

## Setup

1. Install Jenkins using docker

    1.1. [Install Docker & Docker compose](https://docs.docker.com/engine/install/)

    1.2. [Update docker to run without sudo permission](https://docs.docker.com/engine/install/linux-postinstall/)

    1.3. Logging in to your Github account (or your's company Github account)

    **_This Github account need write permission to this repository_**

    1.4. Clone this repo and check out branch **_cicd_**

    - Jenkins will only use Jenkinsfile from this branch to trigger job
    - Check function **_setup_environment_variables_** inside [Jenkinsfile](.cicd/jenkins/Jenkinsfile), update the variables value if necessary

    1.5. Executing bash script to create Jenkins data folder

    ```shell
        sudo ./jenkins/scripts/host-setup.sh
    ```

    1.6. Installing Jenkins

    ```shell
        cd jenkins
        docker compose up -d --build
    ```

2. Allowing Jenkins to authenticate with Github using SSH keys

    2.1. Add SSH keys to Jenkins instance

    - Access to Jenkins (docker) instance

    - [Generating SSH keys or find the keys that already exists](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

    - [Adding SSH keys to ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)

    2.2. Create a **SSH Username with private key** credential in Jenkins

    - Access Jenkins Web UI
    - **_Path_**: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> + Add Credentials
    - **_Kind_**: _SSH Username with private key_
    - **_ID_**: _github-ssh-cred_
    - **_Description_**: _Jenkins uses this key to authenticate with Github_
    - **_Username_**: your github username
    - **_Private key / Enter directly/ Add_**: paste your private SSH key content at step **2.1** here

    2.3. [Add SSH public key (.pub) at step **2.1.** to the Github account at step **1.3**](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

3. Config Github plugin - allow trigger job in Jenkins by Github webhook

    3.1. [Generate Github personal access token (classic)](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

    - Access to the Github account at step **1.3**
    - **_Select scopes_**:
        - **_repo_**
        - **_admin:repo_hook_**

    3.2. Create a **Secret Text** credential in Jenkins

    - Access Jenkins Web UI
    - **_Path_**: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> + Add Credentials
    - **_Kind_**: _Secret text_
    - **_Secret_**: generated token at step **3.1**
    - **_ID_**: _github-access-token-cred_
    - **_Description_**: _Jenkins will use this token credentail for managing webhook, manipulate commit statuses_

        3.3. Config Github Server

    - Access Jenkins Web UI
    - **_Path_**: Dashboard > Manage Jenkins > System : Github / Github Servers
    - Add new Github server with following information:
        - **_API URL_**: <https://api.github.com>
        - **_Credentials_**: select the credential created at step **3.2**
        - Click **_Test connection_** to check your configuration
    - Click Save

4. Config remote server info

    4.1. Add remote server ssh credential in Jenkins

    - Access Jenkins Web UI
    - Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> + Add Credentials
    - **_Kind_**: _SSH Username with private key_
    - **_ID_**: _remote-server-cred_
    - **_Description_**: _Jenkins will use this credential to connect to the remote server and execute commands, scripts._
    - **_Username_**: the server's username
    - **_Private Key / Enter directly / Add_**: the private key use to access the server

    4.2. Allow remote server connect to Github using SSH keys

    4.2.1. Add SSH keys to remote server

    - Access to remote server - the server that Jenkins will deploy code to

    - [Generating SSH keys or find the keys that already exists](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

    - [Adding SSH keys to ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)

    4.2.2. [Add SSH public key (.pub) at step **4.2.1** to the Github account at step **1.3**](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

    4.3. Add privatekey credential

    - Access Jenkins Web UI
    - Path: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> + Add Credentials
    - **_Kind_**: _Secret file_
    - **_File_**: Upload the SSH private key generated at step **4.2.1**
    - **_ID_**: _remote-server-github-privatekey-cred_
    - **_Description_**: _Server use this private key to connect to Github and pull latest code_

5. Create and config Github pipeline on Jenkins

    5.1. Create new pipeline

    - Access Jenkins Web UI
    - Path: Dashboard > New Item -> Pipeline
    - Fill pipeline name. _warning_ [don't put space to pipeline name](https://www.jenkins.io/doc/book/pipeline/getting-started/#:~:text=In%20the%20Enter%20an%20item,handle%20spaces%20in%20directory%20paths.)
    - Check **_Do not allow concurrent builds_**
    - **_Pipeline / Definition_**: **Pipeline script from SCM**
    - **_SCM_**: **Git**
    - **_Repositories / Repository URL_**: paste this repo's **SSH** url
    - Credentials: select the credential you created at step **2.4**
    - Branches to build / Branch Specifier: select an apropriate branch that contains Jenkinsfile, default **_\*/cicd_**
    - Script Path: path to Jenkinsfile in repo, default **_.cicd/jenkins/Jenkinsfile_**
    - Select **_Lightweight checkout_**

        5.2. Config Generic Webhook Trigger

    - Continue updating the pipeline at step **5.1**
    - Check **_Build Triggers/Generic Webhook Trigger_**
    - Given the following **_Post content parameters_** are configured:

        | Variable           | Expression                       | Expression Type | Default value | Value filter |
        | ------------------ | -------------------------------- | --------------- | ------------- | ------------ |
        | action             | $.action                         | JSONPath        |               |              |
        | pr_id              | $.number                         | JSONPath        |               |              |
        | pr_state           | $.pull_request.state             | JSONPath        |               |              |
        | pr_merged          | $.pull_request.merged            | JSONPath        |               |              |
        | pr_to_ref          | $.pull_request.base.ref          | JSONPath        |               |              |
        | pr_to_repo_ssh_url | $.pull_request.base.repo.ssh_url | JSONPath        |               |              |
        | pr_url             | $.pull_request.html_url          | JSONPath        |               |              |
        | pr_draft           | $.pull_request.draft             | JSONPath        |               |              |

    - Fill the **_Token_** with a random string
    - Fill the **_Cause_** with text: Triggered from PR: $pr_url
    - Given **_Optional filter_** is configured with **_Text_**: \$action#\$pr_draft##\$action#\$pr_merged
    - Given **_Optional filter_** is configured with **_Expression_**: (reopened|opened|synchronize|ready_for_review)#(false)##|##(closed)#(true)

    5.3. Add remote server information

    - Jenkins will use these variable for CD process (deploy to remote server)
    - Continue updating the pipeline at step **5.1**
    - Select **Prepare an environment for the run**
    - Select **Keep Jenkins Environment Variables**
    - Select **Keep Jenkins Build Variables**
    - **_Properties Content_**: add below variables with appropriate value

        ```conf
        server_host=<server ip address here>
        server_docker_compose_path=<path to folder contain odoo docker-compose.yml file>
        server_config_file=<path to odoo config file>
        server_custom_addons_path=<path to custom addons folder, also a git repo>
        ```

        for example:

        ```conf
        server_host=12.34.56.78
        server_docker_compose_path=/opt/odoo/
        server_config_file=/opt/odoo/odoo.conf
        server_custom_addons_path=/opt/odoo/custom_addons
        ```

6. [Create Github webhook](https://docs.github.com/en/webhooks/using-webhooks)

    6.1. If you use a local server to receive webhook, [reference this guide](https://gist.github.com/xmars4/c38eb27b97b23b05ae6a0173941e1d85) to expose Jenkins locally to internet

    6.2. Add Jenkins's hook url to repo's webhook

    - Open this Github repo page
    - Path: Settings / Webhooks / Add webhook
    - **_Payload URL_**: <the_public_jenkins_url>/generic-webhook-trigger/invoke?token=<the_Token_at_step_5.2>
    - **_Content type_**: application/json
    - **_Which events would you like to trigger this webhook?_** : _Let me select individual events./ Pull requests_
    - Click : Add webhook

7. Integration with SonarQube

    7.1. Install SonarQube

    - Install SonarQube and allow Jenkins to connect to it (already done in docker compose file at step **_1.6_**)
    - Access SonarQube UI and [generate a user token](https://docs.sonarsource.com/sonarqube/latest/user-guide/user-account/generating-and-using-tokens/#generating-a-token)

    7.2. Add SonarQube installer to Jenkins

    - Access Jenkins Web UI
    - Path: Dasboard / Manage Jenkins / Tools / SonarQube Scanner
    - Click _Add SonarQube Scanner_
        - Input Name: **sonarqube-scanner**
        - Check: **Install automatically**

    7.3. Add SonarQube credentail to Jenkins

    - Access Jenkins Web UI
    - **_Path_**: Dashboard > Manage Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> + Add Credentials
    - **_Kind_**: _Username with password_
    - **_Username_**: the SonarQube url which Jenkins can connect
    - **_Secret_**: the token was obtained from step 7.1
    - **_ID_**: _sonar-cred_
    - **_Description_**: _Jenkins will use this url and token to connect to SonarQube_

8. Send message to Telegram from Jenkins

    - Follow [this link](https://gist.github.com/xmars4/25931e4e59476da70a183d0f5a1d9e9e) to obtain **BOT token** and **Channel ID**
    - Add two secret text credentails to your Jenkins instance
        - **_ID_**: **telegram-bot-token** **_Secret_**: BOT token
        - **_ID_**: **telegram-channel-id** **_Secret_**: Channel ID

9. Trigger build process manually

    - **You have to trigger build process first time manually before Github webhook can trigger the build process automatically**

    - Path: Dashboard / Your pipeline / Build Now

:zap::zap:**Congrats**:v::v: : now your pipeline will automatic start building when the repo received a pull request commit

## Reference

- ![Flow](docs/img/CI-CD-flow.png)

- Jenkins plugins:

    - [Github](https://plugins.jenkins.io/github/)
    - [SSH Agent](https://plugins.jenkins.io/ssh-agent/)
    - [Versions Node Monitors](https://plugins.jenkins.io/versioncolumn/)
    - [SonarQube Scanner](https://plugins.jenkins.io/sonar/)
    - [SSH Pipeline Steps](https://plugins.jenkins.io/ssh-steps/)
    - [Environment Injector](https://plugins.jenkins.io/envinject/)
    - [Generic Webhook Trigger](https://plugins.jenkins.io/generic-webhook-trigger/)

- Run Jenkins from [docker-compose.yml](jenkins-docker-compose/docker-compose.yml) file using a **[bind mount](https://github.com/jenkinsci/docker/blob/master/README.md#usage)** volume:

    ```bash
    touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
    Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?
    ```

    -> Solution:

    ```bash
    sudo mkdir -p /var/jenkins_home && sudo chown -R 1000:1000 /var/jenkins_home/
    ```

- [Why use bind mount volume instead of volume for Jenkins' container](https://stackoverflow.com/questions/62678663/jenkins-in-docker-clarification-about-bind-mounts-in-pipelines/62679925#62679925)

- [SonarQube](https://docs.sonarsource.com/sonarqube/latest/) code quality inspection -> use to scan Odoo addons

- [wait-for-it.sh bash script](https://github.com/vishnubob/wait-for-it)
- [Manage java versions on controller and nodes
    ](https://www.youtube.com/watch?v=ZabUz6sl-8I)

- [Binding credentails to variable](https://www.jenkins.io/doc/pipeline/steps/credentials-binding/)
- permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock

    -> Solution:
    check Jenkins Dockerfile, line 17,18, 19 to create a new group mapped with docker group on host

- Config Generic webhook trigger in Jenkins file

    ```java
    node {
        withCredentials([string(credentialsId: 'github-access-token-cred', variable: 'webhookToken')]) {
            properties([
                pipelineTriggers([
                    [
                        $class: 'GenericTrigger',
                        genericVariables: [
                            [key: 'action', value: '$.action', expressionType: 'JSONPath'],
                            [key: 'pr_id', value: '$.number', expressionType: 'JSONPath'],
                            [key: 'pr_state', value: '$.pull_request.state', expressionType: 'JSONPath'],
                            [key: 'pr_merged', value: '$.pull_request.merged', expressionType: 'JSONPath'],
                            [key: 'pr_to_ref', value: '$.pull_request.base.ref', expressionType: 'JSONPath'],
                            [key: 'pr_to_repo_ssh_url', value: '$.pull_request.base.repo.ssh_url', expressionType: 'JSONPath'],
                            [key: 'pr_url', value: '$.pull_request.html_url', expressionType: 'JSONPath'],
                            [key: 'pr_draft', value: '$.pull_request.draft', expressionType: 'JSONPath']
                        ],
                        causeString: 'Triggered from PR: $pr_url',
                        token: webhookToken,
                        regexpFilterText: '$action#$pr_draft##$action#$pr_merged',
                        regexpFilterExpression: '(reopened|opened|synchronize|ready_for_review)#(false)##|##(closed)#(true)',
                        printContributedVariables: false,
                        printPostContent: false,
                    ]
                ])
            ])
        }

        stage ...
    }
    ```

- By default, before pipeline start, Jenkins will check out repo with branch specified in 'Branches to build' to get the Jenkinsfile,\
so we can't ignore check out default Instead, we will perform second checkout with specific branch (from pull request)
