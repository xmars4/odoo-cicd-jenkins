#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
is_pylint_build=$1

function set_list_addons {
    if [[ $is_pylint_build == "true" ]]; then
        return 0
    fi

    declare -g custom_addons=$(get_list_addons_should_run_test "$ODOO_CUSTOM_ADDONS_PATH")
    if [ -z $custom_addons ]; then
        show_separator "Can't find any Odoo custom modules, please recheck your config!"
        exit 1
    fi

    ignore_demo_data_addons=$(get_list_addons_ignore_demo_data "$ODOO_CUSTOM_ADDONS_PATH")
    declare -g without_demo_addons=
    if [[ -z $ignore_demo_data_addons ]]; then
        without_demo_addons=all
    else
        without_demo_addons=$ignore_demo_data_addons
    fi
}

function update_config_file {
    # Odoo's suggestion:  Unit testing in workers mode could fail; use --workers 0.
    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    sed -i "s/^\s*without_demo\s*.*//g" $CONFIG_FILE
    tagged_custom_addons=$(echo $custom_addons | sed "s/,/,\//g" | sed "s/^/\//")
    if [[ $is_pylint_build == "true" ]]; then
        echo -e "\ncommand = --stop-after-init --workers 0 --database $ODOO_TEST_DATABASE_NAME --logfile "$LOG_FILE" --log-level info --load base,web -i test_lint,test_pylint --test-enable --test-tags /test_lint,/test_pylint,/test_lint,/test_pylint,-/test_lint:TestPyLint.test_pylint\n" >>$CONFIG_FILE
    else
        echo -e "\ncommand = --stop-after-init --workers 0 --database $ODOO_TEST_DATABASE_NAME --without-demo $without_demo_addons --logfile "$LOG_FILE" --log-level info -i "${custom_addons}" --test-enable --test-tags "${tagged_custom_addons}"\n" >>$CONFIG_FILE
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
