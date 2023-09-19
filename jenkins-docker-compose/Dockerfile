FROM jenkins/jenkins:lts
WORKDIR /var/jenkins_home

USER root
RUN apt-get update
RUN apt-get install ca-certificates curl gnupg wget apt-transport-https -y
# update java version from 11 -> 17
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
  echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update && apt-get install temurin-17-jdk -y

ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
ENV PATH "${JAVA_HOME}/bin:${PATH}"

# install docker and docker compose commands
RUN groupadd -g 999 docker && \
  usermod -aG staff,docker jenkins
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
RUN jenkins-plugin-cli --plugins "docker-workflow github ssh-agent versioncolumn sonar"
