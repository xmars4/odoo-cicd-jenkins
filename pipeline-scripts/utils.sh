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

# ------------------ Telegram functions -------------------------
send_file_telegram() {
    BOT_TOKEN=$1
    CHAT_ID=$2
    file_path=$3
    caption=$4
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
        -F "chat_id=$CHAT_ID" \
        -F "document=@$file_path" \
        -F "caption=$caption"
}

send_message_telegram() {
    BOT_TOKEN=$1
    CHAT_ID=$2
    message=$3
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$message"
}
# ------------------ Telegram functions -------------------------

ODOO_WORKSPACE="${WORKSPACE}/odoo-docker-compose"
ODOO_IMAGE_TAG="xmars/odoo16-cicd"
EXTRA_ADDONS_PATH="${ODOO_WORKSPACE}/extra-addons"
CONFIG_FILE="${ODOO_WORKSPACE}/etc/odoo.conf"
LOG_FILE="/var/log/odoo/odoo.log" # inside odoo container
