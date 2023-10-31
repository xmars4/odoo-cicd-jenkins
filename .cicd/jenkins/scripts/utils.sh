#!/bin/bash

global_github_access_token=${github_access_token}
global_telegram_bot_token=${telegram_bot_token}
global_telegram_channel_id=${telegram_channel_id}

docker_compose() {
    cd $ODOO_DOCKER_COMPOSE_PATH
    docker compose -p "$ODOO_DOCKER_COMPOSE_PROJECT_NAME" "$@"
}

docker_compose_clean() {
    cd $ODOO_DOCKER_COMPOSE_PATH
    docker_compose down -v
    rm -f $LOG_FILE_OUTSIDE
}

get_config_value() {
    param=$1
    grep -q -E "^\s*\b${param}\b\s*=" "$CONFIG_FILE"
    if [[ $? == 0 ]]; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$CONFIG_FILE" | cut -d " " -f3 | sed 's/["\n\r]//g')
    fi
    echo "$value"
}

function get_list_addons {
    addons=
    res=$(find "$1" -type f -name "__manifest__.py" -exec dirname {} \;)
    for dr in $res; do
        addon_name=$(basename $dr)
        if [[ -z $addons ]]; then
            addons="$addon_name"
        else
            addons="$addons,$addon_name"
        fi
    done

    echo $addons
}

function wait_until_odoo_shutdown {
    # because we put --stop-after-init option to odoo command
    # so after Odoo has finished installing and runing test cases
    # It will shutdown automatically
    # we just need to wait until odoo container is stopped (status=exited)
    # and we can start analyze the log file
    maximum_waiting_time=3600 # maximum wait time is 60', in case if there is an unexpected problem
    odoo_container_id=$(get_odoo_container_id)
    if [ -z $odoo_container_id ]; then
        echo "Can't find the Odoo container, stop pipeline immediately!"
        exit 1
    fi
    sleep_block=5
    total_waited_time=0
    while (($total_waited_time <= $maximum_waiting_time)); do
        container_exited_id=$(docker ps -q --filter "id=$odoo_container_id" --filter "status=exited")
        if [[ -n $container_exited_id ]]; then break; fi
        total_waited_time=$((total_waited_time + sleep_block))
        sleep $sleep_block
    done
}

# declare all useful functions here
show_separator() {
    x="==============================================="
    separator=($x $x "$1" $x $x)
    printf "%s\n" "${separator[@]}"
}

get_odoo_container_id() {
    cd "$ODOO_DOCKER_COMPOSE_PATH"
    docker_compose ps -q -a |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${ODOO_IMAGE_TAG}" '$2 == img {print $1}'
}

docker_odoo_exec() {
    odoo_container_id=$(get_odoo_container_id)
    docker exec $odoo_container_id sh -c "$@"
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

    response=$(curl --write-out '%{http_code}\n' -L -s \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${aab}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/${repo_name}/statuses/${commit_sha} \
        -d "$request_content")
    status_code=$(echo $response | grep -oE "[0-9]+$")
    echo "here response: $response"
    echo "here status code:$status_code"
    if ! [[ $status_code != "201" ]]; then
        echo "Can't set Github commit status!"
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
