FROM jenkins/jenkins:lts
WORKDIR /var/jenkins_home

USER root
RUN mkdir -p /tmp/download && \
 curl -L https://download.docker.com/linux/static/stable/x86_64/docker-24.0.6.tgz | tar -xz -C /tmp/download && \
 rm -rf /tmp/download/docker/dockerd && \
 mv /tmp/download/docker/docker* /usr/local/bin/ && \
 rm -rf /tmp/download && \
 groupadd -g 999 docker && \
 usermod -aG staff,docker jenkins

USER jenkins

# add github to known hosts so we Github will be allowed to connect to Jenkins
RUN mkdir .ssh && touch .ssh/known_hosts
RUN ssh-keyscan github.com >> .ssh/known_hosts