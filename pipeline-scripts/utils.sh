#!/bin/bash

# declare all useful functions here
function show_separator {
    x="==============================================="
    separator=($x $x "$1" $x $x)
    printf "%s\n" "${separator[@]}"
}

function get_odoo_container_id {
    docker compose ps -q |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${ODOO_IMAGE_TAG}" '$2 == img {print $1}'
}

check_variable_missing_value() {
    variable_name=$1
    # ! is used to get variable value instead of its name
    if [ -z ${!variable_name} ]; then
        show_separator "ERROR: Mising variable named '$variable_name' or its value is empty"
        exit 1
    fi
}

get_repo_name() {
    repo_url=$1
    if ! [[ "$repo_url" =~ ^git@ ]]; then
        repo_name=$(echo "$repo_url" | sed "s/.*:\/\/[^/]*\///" | sed "s/\.git$//")
    else
        repo_name=$(echo "$repo_url" | sed "s/.*://" | sed "s/\.git$//")
    fi
    echo $repo_name
}

get_commit_sha() {
    echo $(git rev-parse HEAD)
}

set_github_commit_status() {
    repo_name=$1
    commit_sha=$2
    github_access_token=$3
    state=$4
    message=$5
    build_url=$6
    context=$7
    if [ -z $context ]; then
        context="continuous-integration/jenkins"
    fi
    if [ -z $build_url ]; then
        build_url=$BUILD_URL
    fi

    curl -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${github_access_token}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/${repo_name}/statuses/${commit_sha} \
        -d '{"state":'"${state}"',"target_url":'"${build_url}"',"description":'"${message}"',"context":'"${context}"'}'
}

set_github_commit_status_default() {
    repo_name=$(get_repo_name)
    commit_sha=$(get_commit_sha)
    github_access_token=$1
    state=$2
    message=$3
    set_github_commit_status "$repo_name" "$commit_sha" "$github_access_token" "$state" "$message"
}

# ------------------ Telegram functions -------------------------
send_file_telegram() {
    bot_token=$1
    chat_id=$2
    file_path=$3
    caption=$4
    curl -s -X POST "https://api.telegram.org/bot$bot_token/sendDocument" \
        -F "chat_id=$chat_id" \
        -F "document=@$file_path" \
        -F "caption=$caption"
}

send_message_telegram() {
    bot_token=$1
    chat_id=$2
    message=$3
    curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
        -d "chat_id=$chat_id" \
        -d "text=$message"
}
# ------------------ Telegram functions -------------------------

if [ $# -gt 0 ]; then
    function_name=$1
    shift
    if declare -f "$function_name" >/dev/null; then
        "$function_name" $@
    else
        echo "Function '$function_name' does not exist."
        exit 1
    fi
fi
