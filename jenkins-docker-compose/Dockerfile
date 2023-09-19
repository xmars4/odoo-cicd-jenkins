FROM jenkins/jenkins:lts
WORKDIR /var/jenkins_home

USER root

RUN groupadd -g 999 docker && \
  usermod -aG staff,docker jenkins

RUN apt-get update
RUN apt-get install ca-certificates curl gnupg
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && \
  apt-get install docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

USER jenkins
RUN jenkins-plugin-cli --plugins "docker-workflow github ssh-agent sonar"

RUN mkdir -p /.ssh/ && touch /.ssh/.known_hosts
