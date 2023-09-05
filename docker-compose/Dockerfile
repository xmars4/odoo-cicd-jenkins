FROM jenkins/jenkins:lts

WORKDIR /var/jenkins_home
RUN mkdir .ssh && touch .ssh/known_hosts

# add github to known hosts so we Github will be allowed to connect to Jenkins
RUN ssh-keyscan github.com >> .ssh/known_hosts

USER jenkins
