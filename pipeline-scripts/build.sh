#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
ODOO_WORKSPACE="${ODOO_WORKSPACE}"
EXTRA_ADDONS_PATH="${ODOO_WORKSPACE}/extra-addons"
ODOO_CONFIG_FILE="${ODOO_WORKSPACE}/etc/odoo.conf"
#####
#####
show_separator "Rebuild Odoo image"
cd $ODOO_WORKSPACE
cd dockerfile && docker build -t xmars/odoo16-cicd .

####
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

#####
function update_config_file {
    # we use log to analytic error, so log_level should be 'error'
    # remove old log level command
    sed -i "s/^\s*log_level\s*.*//g" $ODOO_CONFIG_FILE
    echo "log_level = error" >>$ODOO_CONFIG_FILE

    # replace old command argument
    sed -i "s/^\s*command\s*.*//g" $ODOO_CONFIG_FILE
    echo "command = -i "${EXTRA_ADDONS}" --test-enable --test-tags "${EXTRA_ADDONS}"" >>$ODOO_CONFIG_FILE
}
update_config_file

docker compose up -d --wait --no-color
docker compose ps

cat $ODOO_CONFIG_FILE
ls -lah $ODOO_WORKSPACE

cat "${ODOO_WORKSPACE}/logs/odoo.log"
