#!/bin/bash
server_docker_compose_path=$1
server_extra_addons_path=$2
server_config_file=$3
EXTRA_ADDONS=

pull_latest_addons() {
    cd "${server_extra_addons_path}"
    echo "here all data"
    ls -lah .
    git pull origin
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
    pull_latest_addons
    set_list_addons
    update_config_file
    update_odoo_services
}

main
