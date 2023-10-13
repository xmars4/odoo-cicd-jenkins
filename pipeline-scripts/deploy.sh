#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
server_deploy_script=/tmp/odoo-cicd-deploy.sh
git_private_key_file="/tmp/odoo-cicd-git-privkey"

check_required_variables() {
    check_variable_missing_value "server_host"
    check_variable_missing_value "server_docker_compose_path"
    check_variable_missing_value "server_extra_addons_path"
    check_variable_missing_value "server_config_file"
    check_variable_missing_value "git_private_key_file"
}

presetup_ssh_remote() {
    ssh-keygen -R $server_host
    ssh-keyscan $server_host >>"${HOME}/.ssh/known_hosts"
}

execute_remote_command() {
    ssh "${server_username}"@"${server_host}" -i "${server_privatekey}" $1
}

execute_remote_script() {
    script_name=$1
    shift
    execute_remote_command "chmod +x ${script_name}"
    ssh "${server_username}"@"${server_host}" -i "${server_privatekey}" "${script_name} $@"
}

copy_and_execute_deploy_script_on_server() {
    echo 'a=============================\\\\\\\\\\\\\\\\\'
    cat ${WORKSPACE}/pipeline-scripts/server_deploy.sh
    scp -i "${server_privatekey}" \
        -f "${WORKSPACE}/pipeline-scripts/server_deploy.sh" \
        "${server_username}"@"${server_host}":"${server_deploy_script}"
    echo "how was the copying $?"

    execute_remote_script $server_deploy_script \
        $server_docker_compose_path \
        $server_extra_addons_path \
        $server_config_file \
        $git_private_key_file
}

copy_github_privatekey_to_server() {
    scp -i "${server_privatekey}" \
        "${server_github_privatekey_file}" \
        "${server_username}"@"${server_host}":"${git_private_key_file}"
}

main() {
    check_required_variables
    presetup_ssh_remote
    copy_github_privatekey_to_server
    copy_and_execute_deploy_script_on_server
}

main
