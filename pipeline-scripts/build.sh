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
    echo -e "\nlog_level = info" >>$CONFIG_FILE
    # FIXME: update info -> error
    # echo -e "\nlog_level = error" >>$CONFIG_FILE

    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    echo -e "\ncommand = -i "${EXTRA_ADDONS}" --test-enable --test-tags "${EXTRA_ADDONS}"" >>$CONFIG_FILE

}

function start_containers {
    docker compose up -d --wait --no-color
    docker ps
}

function waiting_for_odoo_fully_up {
    # althrough docker check odoo + db services are healthy
    # but Odoo is still intalling and running test cases for modules
    # so have to wait Odoo is truly done process
    # before go to the next step (Test)
    # TODO: WAIT here
    echo 'fully up'
}

function main {
    show_separator "Install Odoo and run test cases for all modules in extra-addons folder"
    build_odoo_image
    set_list_addons
    update_config_file
    start_containers
    waiting_for_odoo_fully_up
}
