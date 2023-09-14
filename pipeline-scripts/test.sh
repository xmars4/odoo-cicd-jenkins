#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

function get_odoo_container_id {
    docker compose ps -q |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${ODOO_IMAGE_TAG}" '$2 == img {print $1}'
}

ODOO_CONTAINER_ID=$(get_odoo_container_id)

show_separator "Start analyzing log file"

sleep 30
function get_odoo_log {

    # ERROR_LINES_FAIL=($(echo "foo|bar" | { grep -P '^.*ERROR.*odoo.addons.*\.tests\..*$' $LOG_FILE || true; }))
    ERROR_LINES_FAIL=($(docker exec $ODOO_CONTAINER_ID sh -c "echo \"foo|bar\" | { grep -P '^.*ERROR.*odoo.addons.*\.tests\..*$' $LOG_FILE || true;"))
}

echo $(get_odoo_log)
