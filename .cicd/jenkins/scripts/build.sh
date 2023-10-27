#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
is_pylint_build=$1

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

function set_list_addons {
    if [[ $is_pylint_build == "true" ]]; then
        return 0
    fi
    CUSTOM_ADDONS=$(get_list_addons "$ODOO_CUSTOM_ADDONS_PATH")
    if [ -z $CUSTOM_ADDONS ]; then
        show_separator "Can't find any Odoo custom modules, please recheck your config!"
        exit 1
    fi
}

function update_config_file {
    # Odoo's suggestion:  Unit testing in workers mode could fail; use --workers 0.
    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    if [[ $is_pylint_build == "true" ]]; then
        echo -e "\ncommand = --stop-after-init --workers 0 --database test --logfile "$LOG_FILE" --log-level info --load base,web -i test_lint,test_pylint --test-enable --test-tags /test_lint,/test_pylint,/test_lint,/test_pylint,-/test_lint:TestPyLint.test_pylint\n" >>$CONFIG_FILE
    else
        echo -e "\ncommand = --stop-after-init --workers 0 --database test --logfile "$LOG_FILE" --log-level info -i "${CUSTOM_ADDONS}" --test-enable --test-tags "${CUSTOM_ADDONS}"\n" >>$CONFIG_FILE
    fi
}

function start_containers {
    default_container_requirements="$ODOO_WORKSPACE/dockerfile/requirements.txt"
    custom_addons_requirements="$ODOO_CUSTOM_ADDONS_PATH/requirements.txt"
    if [ -e "$custom_addons_requirements" ] && [ -e "$default_container_requirements" ]; then
        echo "" >>$default_container_requirements
        cat "$custom_addons_requirements" >>$default_container_requirements
    fi
    docker_compose build --pull --quiet
    docker_compose up -d --wait --no-color
    docker_compose ps
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

show_build_message() {
    if [[ $is_pylint_build == "true" ]]; then
        show_separator "Install and run pylint test cases for custom addons!"
    else
        show_separator "Install and run test cases for custom addons!"

    fi
}

function main {
    show_build_message
    set_list_addons
    update_config_file
    start_containers
    wait_until_odoo_shutdown
}

main
