#!/bin/bash

show_separator "Rebuild Odoo image"

cd "${WORKSPACE}/odoo-docker-compose"
cd dockerfile && docker build -t xmars/odoo16-cicd .

echo "____________________Install all modules in extra-addons folder_____________________"
EXTRA_ADDONS_PATH="${WORKSPACE}/odoo-docker-compose/extra-addons"
echo "____________Get list addons_____________"

function get_list_addons {
    if [[ $# -gt 0 ]]; then
        cd "$1"
    fi
    find . -maxdepth 1 -mindepth 1 -not -path '*/\.*' -type d -printf "%f,"
}
EXTRA_ADDONS=$(get_list_addons "$EXTRA_ADDONS_PATH")

function add_command_to_config {
    echo 1
}

docker compose up -d --wait --no-color
docker compose ps
