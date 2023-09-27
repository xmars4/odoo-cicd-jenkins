#!/bin/bash
server_docker_compose_path=$1
server_extra_addons_path=$2
server_config_file=$3
repo_remote_name="origin"
EXTRA_ADDONS=

access_git_remote_repo() {

}

get_git_remote_url() {

}

setup_git_ssh_remote() {
    # $1 parameter: git repo path
    if [[ $# -eq 0 ]]; then
        echo "Mising first param: path to git repo!"
        exit 1
    fi
    cd "$1"
    # 1. find existing remote name
    remote_url=$(git remote get-url $repo_remote_name | head -n 1)

    remote_ssh_reg="^git@"
    if ! [[ $remote_url =~ $remote_ssh_reg ]]; then
        # the remote url is http(s) url
        repo_name=$(echo "$remote_url" | sed "s/.*:\/\/[^/]*\///")
        repo_host=$(echo "$remote_url" | sed "s/\/[^/]*\/[^/]*$//" | sed "s/^.*\/\///")
        # re-build repo's ssh url
        # so we can setup and use git command authenticate by ssh private key
        remote_url="git@$repo_host:$repo_name"
        git remote set-url $repo_remote_name $remote_url
    fi
}

setup_git_ssh_key_for_repo() {
    # $1 - path to git repo directory (source code)
    # empty if we stand in current path
    if [[ $# -gt 0 ]]; then
        cd "$1"
    fi
    git fetch
    if [[ $? -gt 0 ]]; then
        # if fetch command failed, try to setup private key for repo
        remote_url=$(git remote get-url origin | head -n 1)
        if [[ $remote_url =~ "^git@" ]]; then
            echo 'hihi'
        fi
    fi
}

pull_latest_code() {
    cd "${server_extra_addons_path}"
    git pull
}

get_list_addons() {
    if [[ $# -gt 0 ]]; then
        cd "$1"
    fi
    find . -maxdepth 1 -mindepth 1 -not -path '*/\.*' -type d -printf "%f," | sed 's/.$//'
}

set_list_addons() {
    EXTRA_ADDONS=$(get_list_addons "$server_extra_addons_path")
    if [ -z $EXTRA_ADDONS ]; then
        show_separator "Can't find any module in extra-addons folder"
        exit 1
    fi
}

update_config_file() {
    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $server_config_file
    echo -e "\ncommand = -u "${EXTRA_ADDONS}"\n" >>"${server_config_file}"
}

update_odoo_services() {
    cd "${server_docker_compose_path}"
    docker compose restart
}

main() {
    pull_latest_code
    set_list_addons
    update_config_file
    update_odoo_services
}

main
