#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

function get_odoo_container_id {
    docker compose ps -q |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${ODOO_IMAGE_TAG}" '$2 == img {print $1}'
}

ODOO_CONTAINER_ID=$(get_odoo_container_id)
show_separator "id here ${ODOO_CONTAINER_ID}"
show_separator "Start analyzing log file"

function get_odoo_log {
    # in case Odoo don't have any ERROR -> log file will be not generated
    # so no need to analyze log anymore
    docker exec $ODOO_CONTAINER_ID sh -c "[ -f ${LOG_FILE} ]"
    if [ $? != 0 ]; then
        return
    fi
    # docker exec $ODOO_CONTAINER_ID sh -c "grep -P '^.*ERROR.*odoo.addons.*\.tests\..*$' $LOG_FILE || true;"
    docker exec $ODOO_CONTAINER_ID sh -c "grep -P 'Starting' $LOG_FILE || true;"
}

LINES_FAIL_TEST=$(get_odoo_log)
echo $LINES_FAIL_TEST
