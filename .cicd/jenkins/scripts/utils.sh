#!/bin/bash

global_github_access_token=${github_access_token}
global_telegram_bot_token=${telegram_bot_token}
global_telegram_channel_id=${telegram_channel_id}

docker_compose() {
    cd $ODOO_DOCKER_COMPOSE_PATH
    docker compose -q $ODOO_DOCKER_COMPOSE_PROJECT_NAME "$@"
}

# declare all useful functions here
show_separator() {
    x="==============================================="
    separator=($x $x "$1" $x $x)
    printf "%s\n" "${separator[@]}"
}

get_odoo_container_id() {
    docker_compose ps -q -a |
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

get_repo_url() {
    echo $(git config --get remote.origin.url)
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

    request_content="{\"state\":\"${state}\",\"target_url\":\"${build_url}\",\"description\":\"${message}\",\"context\":\"${context}\"}"

    response=$(curl -L -s \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${github_access_token}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/${repo_name}/statuses/${commit_sha} \
        -d "$request_content")
    if ! [[ $response =~ '"created_at":' ]]; then
        # can't set commit status
        echo $response
    fi

}

set_github_commit_status_default() {
    repo_url=$(get_repo_url)
    repo_name=$(get_repo_name "$repo_url")
    commit_sha=$(get_commit_sha)
    github_access_token=${global_github_access_token}
    state=$1
    message=$2
    set_github_commit_status "$repo_name" "$commit_sha" "$github_access_token" "$state" "$message"
}

# ------------------ Telegram functions -------------------------
send_file_telegram() {
    bot_token=$1
    chat_id=$2
    file_path=$3
    caption=$4
    parse_mode=$5
    [ -z $parse_mode ] && parse_mode="MarkdownV2"

    response=$(curl -s -X POST "https://api.telegram.org/bot$bot_token/sendDocument" \
        -F "chat_id=$chat_id" \
        -F "document=@$file_path" \
        -F "caption=$caption" \
        -F "parse_mode=$parse_mode" \
        -F "disable_notification=true")
    if [[ $response =~ "{\"ok\":false" ]]; then
        echo $response
    fi
}

send_message_telegram() {
    bot_token=$1
    chat_id=$2
    message=$3
    parse_mode=$4
    [ -z $parse_mode ] && parse_mode="MarkdownV2"

    response=$(curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
        -d "chat_id=$chat_id" \
        -d "text=$message" \
        -d "parse_mode=$parse_mode" \
        -d "disable_notification=true")
    if [[ $response =~ "{\"ok\":false" ]]; then
        echo $response
    fi
}

send_file_telegram_default() {
    file_path=$1
    caption=$2
    send_file_telegram "$global_telegram_bot_token" "$global_telegram_channel_id" "$file_path" "$caption"
}

send_message_telegram_default() {
    message=$1
    send_message_telegram "$global_telegram_bot_token" "$global_telegram_channel_id" "$message"
}
# ------------------ Telegram functions -------------------------

if [ $# -gt 0 ]; then
    is_exec_command=$1
    function_name=$2
    shift 2
    if declare -f "$function_name" >/dev/null; then
        if [ $is_exec_command == "exec" ]; then
            "$function_name" "$@"
        fi
    fi
fi
