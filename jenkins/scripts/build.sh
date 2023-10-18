#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
EXTRA_ADDONS=

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
    # Odoo's suggestion:  Unit testing in workers mode could fail; use --workers 0.
    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    echo -e "\ncommand = --stop-after-init --workers 0 --database test --logfile "$LOG_FILE" --log-level error -i "${EXTRA_ADDONS}" --test-enable --test-tags "${EXTRA_ADDONS}"\n" >>$CONFIG_FILE
}

function start_containers {
    cd $ODOO_DOCKER_COMPOSE_PATH
    default_container_requirements="$ODOO_WORKSPACE/dockerfile/requirements.txt"
    custom_addons_requirements="$ODOO_ADDONS_PATH/requirements.txt"
    if [ -e "$custom_addons_requirements" ] && [ -e "$default_container_requirements" ]; then
        echo "" >>$default_container_requirements
        cat "$custom_addons_requirements" >>$default_container_requirements
    fi
    cat $default_container_requirements
    cat $custom_addons_requirements
    show_separator 'delete me later'
    docker compose up -d --wait --no-color --build
    docker compose ps
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
    set_list_addons
    update_config_file
    start_containers
    wait_until_odoo_shutdown
}

main
