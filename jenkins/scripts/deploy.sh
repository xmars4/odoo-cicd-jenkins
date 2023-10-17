#!/bin/bash
server_docker_compose_path=$1 # the path to folder container Odoo docker-compose.yml file
server_extra_addons_path=$2   # the absolute path to source code, also the git repository
server_config_file=$3         # the path to Odoo config file
git_private_key_file=$4       # private key on server use to authenticate on Github

original_repo_remote_name="origin"
custom_repo_remote_name="origin-ssh"
custom_repo_host="ssh.github.com"
server_config_file_backup="${server_config_file}.bak"
EXTRA_ADDONS=

check_git_repo_folder() {
    cd $server_extra_addons_path
    git status >/dev/null 2>&1
    if [[ $? -gt 0 ]]; then
        echo "Can't execute git commands because \"$PWD\" folder is not a git repository!"
        exit 1
    fi
}

get_original_remote_url() {
    remote_url=$(git remote get-url $original_repo_remote_name 2>/dev/null)
    if [ -z "$remote_url" ]; then
        other_repo_remote_name=$(git remote show | head -n 1)
        if [ -z "$other_repo_remote_name" ]; then
            exit 1
        fi
        remote_url=$(git remote get-url $other_repo_remote_name)
    fi
    echo "$remote_url"
}

add_custom_repo_remote() {
    repo_name=$1
    custom_remote_url="git@$custom_repo_host:$repo_name"
    git remote add $custom_repo_remote_name $custom_remote_url
    git remote set-url $custom_repo_remote_name $custom_remote_url
}

write_custom_git_host_to_ssh_config() {
    original_repo_host=$1

    config_value="
\n# Custom git host for CI/CD process
Host $custom_repo_host
  Hostname $original_repo_host
  IdentityFile $git_private_key_file
  IdentitiesOnly yes\n
    "
    if ! grep -q "Host $custom_repo_host" "$ssh_folder/config"; then
        echo -e "$config_value" >>"$ssh_folder/config"
    fi
}

setup_git_ssh_remote() {
    remote_url=$(get_original_remote_url)
    if ! [[ $remote_url =~ ^git@ ]]; then
        repo_name=$(echo "$remote_url" | sed "s/.*:\/\/[^/]*\///" | sed "s/\.git$//")
        repo_host=$(echo "$remote_url" | sed "s/\/[^/]*\/[^/]*$//" | sed "s/^.*\/\///")
        # re-build repo's ssh url
        # so we can setup and use git command authenticate by ssh private key
        remote_url="git@$repo_host:$repo_name"
    else
        repo_name=$(echo "$remote_url" | sed "s/.*://" | sed "s/\.git$//")
        repo_host=$(echo "$remote_url" | sed "s/^git@//" | sed "s/:.*//")
    fi
    add_custom_repo_remote $repo_name
    write_custom_git_host_to_ssh_config $repo_host
}

pull_latest_code() {
    current_branch=$(git branch --show-current)
    remote_url=$(get_original_remote_url)
    if [ -z $remote_url ]; then
        echo "Can't found any valid remote name of git repository in folder ${server_extra_addons_path}"
        exit 1
    fi

    is_first_try_success=1
    if [[ $remote_url =~ ^git@ ]]; then
        # currently, this repo has a remote with ssh url
        # so we try to use it first, before setup other remote ssh
        git pull $original_repo_remote_name $current_branch
        is_first_try_success=$?
    fi
    if [[ $is_first_try_success -ne 0 ]]; then
        setup_git_ssh_remote
        git pull $custom_repo_remote_name $current_branch
    fi
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
    cp $server_config_file $server_config_file_backup
    # replace old command argument
    sed -i "s/^\s*command\s*=.*//g" $server_config_file
    echo -e "\ncommand = -u "${EXTRA_ADDONS}"" >>"${server_config_file}"
}

reset_config_file() {
    rm -rf $server_config_file
    mv $server_config_file_backup $server_config_file
}

update_odoo_services() {
    cd "${server_docker_compose_path}"
    docker compose restart
}

main() {
    check_git_repo_folder
    pull_latest_code
    set_list_addons
    update_config_file
    update_odoo_services
    reset_config_file
}

main
