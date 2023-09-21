#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"

cd "${server_extra_addons_path}" && git pull &&
    cd "${server_docker_compose_path}" && docker compose restart

ssh "${server_username}"@"${server_host}" -i "${server_privatekey}" '''
cd "${server_extra_addons_path}" && git pull &&
  cd "${server_docker_compose_path}" && docker compose restart
    '''
