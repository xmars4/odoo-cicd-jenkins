#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

ODOO_CONTAINER_ID=$(get_odoo_container_id)
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
    cat $CONFIG_FILE
    show_separator 'ok'
    cat $LOG_FILE
}

LINES_FAIL_TEST=$(get_odoo_log)
echo $LINES_FAIL_TEST
