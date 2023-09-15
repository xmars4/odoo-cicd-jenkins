#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
EXTRA_ADDONS=

function build_odoo_image {
    show_separator "Build Odoo image - tag: ${ODOO_IMAGE_TAG}"
    cd "${ODOO_WORKSPACE}/dockerfile"
    docker build -q -t "${ODOO_IMAGE_TAG}" .
}

function get_list_addons {
    if [[ $# -gt 0 ]]; then
        cd "$1"
    fi
    find . -maxdepth 1 -mindepth 1 -not -path '*/\.*' -type d -printf "%f," | sed 's/.$//'
}

function set_list_addons {
    EXTRA_ADDONS=$(get_list_addons "$EXTRA_ADDONS_PATH")
    if [ -z $EXTRA_ADDONS ]; then
        show_separator "Can't find any module in extra-addons folder"
        exit 1
    fi
}

function update_config_file {
    # we use log to analytic error, so log_level should be 'error'
    # remove old log level command
    sed -i "s/^\s*log_level\s*.*//g" $CONFIG_FILE
    # echo -e "\nlog_level = info" >>$CONFIG_FILE
    # FIXME: update info -> error
    echo -e "\nlog_level = error" >>$CONFIG_FILE

    # Odoo suggestion:  Unit testing in workers mode could fail; use --workers 0.
    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    echo -e "\ncommand = --workers 0 -i "${EXTRA_ADDONS}" --test-enable --test-tags "${EXTRA_ADDONS}"" >>$CONFIG_FILE

}

function start_containers {
    docker compose up -d --wait --no-color
    docker ps
}

function wait_until_odoo_available {
    ESITATE_TIME_EACH_ADDON=30
    ODOO_CONTAINER_ID=$(get_odoo_container_id)
    show_separator "Hang on, Modules are being installed ..."
    # Assuming each addon needs 30s to install and run test cases
    # -> we can calculate total sec we have to wait until Odoo is up
    # so the log file will be complete
    IFS=',' read -ra separate_addons_list <<<$EXTRA_ADDONS
    total_addons=${#separate_addons_list[@]}
    # each block wait 5s
    maximum_count=$(((total_addons * ESITATE_TIME_EACH_ADDON) / 5))
    count=1
    while (($count <= $maximum_count)); do
        http_status=$(docker exec "$ODOO_CONTAINER_ID" sh -c 'echo "foo|bar" | { wget --connect-timeout=5 --server-response --spider --quiet "'"${ODOO_URL}"'" 2>&1 | awk '\''NR==1{print $2}'\'' || true; }')
        if [[ $http_status = '200' ]]; then break; fi
        ((count++))
        sleep 5
    done
}

function main {
    show_separator "Install Odoo and run test cases for all modules in extra-addons folder"
    build_odoo_image
    set_list_addons
    update_config_file
    start_containers
    wait_until_odoo_available
}

main
