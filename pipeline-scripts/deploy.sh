#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"

# ssh "${server_username}"@"${server_host}" -i "${server_privatekey}" "cd \"${server_extra_addons_path}\" && git pull && cd \"${server_docker_compose_path}\" && docker compose restart"

# ssh "${server_username}"@"${server_host}" -i "${server_privatekey}" "cd \"${server_extra_addons_path}\" && ls -lah && git log"

execute_remote_command() {
    ssh "${server_username}"@"${server_host}" -i "${server_privatekey}" $1
}

execute_remote_command "cd \"${server_extra_addons_path}\" && ls -lah && git log"
