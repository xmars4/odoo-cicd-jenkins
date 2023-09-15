#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"

#####
#####
show_separator "Rebuild Odoo image"
cd $ODOO_WORKSPACE
cd dockerfile && docker build -q -t "${ODOO_IMAGE_TAG}" .

#####
#####
show_separator "Install and run test cases for all modules in extra-addons folder"

#####
function get_list_addons {
    if [[ $# -gt 0 ]]; then
        cd "$1"
    fi
    find . -maxdepth 1 -mindepth 1 -not -path '*/\.*' -type d -printf "%f," | sed 's/.$//'
}
EXTRA_ADDONS=$(get_list_addons "$EXTRA_ADDONS_PATH")
if [ -z $EXTRA_ADDONS ]; then
    exit 1
fi
#####
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
update_config_file

docker compose up -d --wait --no-color
docker ps
