#!/bin/bash

# because bind mount to non-empty container folder
# will obsecure all existing files -> we have to preallocate all the data in the source (host) directory first 
# https://docs.docker.com/storage/bind-mounts/#mount-into-a-non-empty-directory-on-the-container
mkdir -p /var/jenkins_home/.ssh
cd /var/jenkins_home/.ssh
touch known_hosts
# add github to known hosts so Github will be allowed to connect to Jenkins
ssh-keyscan github.com >> known_hosts
# add appropriate permission for jenkins user (inside container)
chown -R 1000:1000 /var/jenkins_home