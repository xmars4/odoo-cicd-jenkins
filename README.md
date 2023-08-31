# Odoo with CI/CD - Jenkins

-   [SonarQube](https://docs.sonarsource.com/sonarqube/latest/) code quality inspection -> use to scan Odoo addons

-   Install ssh-agent plugin to connect to Github, Gitlab or other server with credentials (see example in [ssh-agent/Jenkinsfile](ssh-agent/Jenkinsfile))

# Setup

1. Install Jenkins and some useful plugins

    1.1. [Install Jenkins](https://www.jenkins.io/doc/book/installing/)

    1.2. [Install Github plugin](https://plugins.jenkins.io/github/)

    1.3. [Install ssh-agent](https://plugins.jenkins.io/ssh-agent/)

2. Allow Jenkins connect to Github - with SSH key

    2.1. [Generate SSH key or find an existing on Jenkins's host](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)

    2.2. [Add SSH key to ssh-agent](https://www.jenkins.io/doc/book/installing/)

    2.3. [Add SSH public key (.pub) to Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

3. Config Jenkins's plugins

    3.1. Add Github credential's to Jenkins

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
