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
    EXTRA_ADDONS=$(get_list_addons "$ODOO_ADDONS_PATH")
    if [ -z $EXTRA_ADDONS ]; then
        show_separator "Can't find any module in extra-addons folder"
        exit 1
    fi
}

function update_config_file {
    # we use log to analytic error, so log_level should be 'error'
    # remove old log level command
    sed -i "s/^\s*log_level\s*.*//g" $CONFIG_FILE
    echo -e "\nlog_level = warn" >>$CONFIG_FILE

    # Odoo's suggestion:  Unit testing in workers mode could fail; use --workers 0.
    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    echo -e "\ncommand = --stop-after-init --workers 0 --database test --logfile "$LOG_FILE" -i "${EXTRA_ADDONS}" --test-enable --test-tags "${EXTRA_ADDONS}"\n" >>$CONFIG_FILE
}

function start_containers {
    docker compose up -d --wait --no-color
    docker compose ps
}

function wait_until_odoo_shutdown {
    # because we put --stop-after-init option to odoo command
    # so after Odoo finish install and run test cases
    # It will shutdown automatically
    # we just need to wait until odoo container stopped (status=exited)
    # and we can analyze the log file
    maximum_waiting_time=3600 # maximum wait time is 60', in the case there is unexpected problem
    odoo_container_id=$(get_odoo_container_id)
    if [ -z $odoo_container_id ]; then
        echo "Can't find the Odoo container, stop pipeline immediately!"
        exit 1
    fi
    sleep_block=5
    total_waited_time=0
    while (($total_waited_time <= $maximum_waiting_time)); do
        container_exited_id=$(docker ps -q --filter "id=$odoo_container_id" --filter "status=exitted")
        if [[ -n $container_exited_id ]]; then break; fi
        total_waited_time=$((total_waited_time + sleep_block))
        sleep $sleep_block
    done
}

function wait_until_odoo_available {
    ESITATE_TIME_EACH_ADDON=30
    ODOO_CONTAINER_ID=$(get_odoo_container_id)
    if [ -z $ODOO_CONTAINER_ID ]; then
        echo "Can't find the Odoo container, stop pipeline immediately!"
        exit 1
    fi
    show_separator "Hang on, Modules are being installed ..."
    # Assuming each addon needs 30s to install and run test cases
    # -> we can calculate total sec we have to wait until Odoo is up
    # and the log file will be complete
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
    wait_until_odoo_shutdown
}

main
