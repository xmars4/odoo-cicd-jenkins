#!/bin/bash
server_docker_compose_path=$1
server_extra_addons_path=$2
server_config_file=$3
repo_remote_name="origin"
EXTRA_ADDONS=

check_current_dir_is_a_git_repo() {
    git status
    if [[ $? -gt 0 ]]; then
        echo "Can't execute git commands because current folder is not a git repo!"
        exit 1
    fi
}

get_git_remote_url() {
    check_current_dir_is_a_git_repo
    remote_url=$((git remote get-url $repo_remote_name | head -n 1) 2>/dev/null)

    # provided remote named $repo_remote_name doesn't exist
    if [ -z "$remote_url" ]; then
        exist_remote_name=$(git remote show | head -n 1)
        if [ -z "$exist_remote_name" ]; then
            return
        fi
        remote_url=$(git remote get-url $exist_remote_name | head -n 1)
    fi
    echo "$remote_url"
}

setup_git_ssh_remote() {
    check_current_dir_is_a_git_repo
    git remote add $repo_remote_name temp_url
    remote_url=$(get_git_remote_url)
    remote_ssh_reg="^git@"

    if ! [[ $remote_url =~ $remote_ssh_reg ]]; then
        # the remote url is http(s) url
        repo_name=$(echo "$remote_url" | sed "s/.*:\/\/[^/]*\///")
        repo_host=$(echo "$remote_url" | sed "s/\/[^/]*\/[^/]*$//" | sed "s/^.*\/\///")
        # re-build repo's ssh url
        # so we can setup and use git command authenticate by ssh private key
        remote_url="git@$repo_host:$repo_name"
    fi
    git remote set-url $repo_remote_name $remote_url
}

pull_latest_code() {
    # $1 : path to ssh private key to authenticate with Github
    check_current_dir_is_a_git_repo
    git fetch
    if [[ $? -gt 0 ]]; then
        # fetch command failed because invalid git authentication
        # setup ssh and re-try
        setup_git_ssh_remote
    fi
    current_branch=$(git branch --show-current)
    ssh-agent bash -c "ssh-add \"$1\"; git pull $repo_remote_name current_branch"
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
