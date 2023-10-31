#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
is_pylint_build=$1

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
        echo -e "\ncommand = --stop-after-init --workers 0 --database $ODOO_TEST_DATABASE_NAME --logfile "$LOG_FILE" --log-level info --load base,web -i test_lint,test_pylint --test-enable --test-tags /test_lint,/test_pylint,/test_lint,/test_pylint,-/test_lint:TestPyLint.test_pylint\n" >>$CONFIG_FILE
    else
        echo -e "\ncommand = --stop-after-init --workers 0 --database $ODOO_TEST_DATABASE_NAME --logfile "$LOG_FILE" --log-level info -i "${CUSTOM_ADDONS}" --test-enable --test-tags "${CUSTOM_ADDONS}"\n" >>$CONFIG_FILE
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
