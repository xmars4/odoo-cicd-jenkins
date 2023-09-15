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
    # FIXME: grep real error here
    docker exec $ODOO_CONTAINER_ID sh -c "grep -P '^.*ERROR.*odoo.addons.*\.tests\..*$' $LOG_FILE || true;"
    # docker exec $ODOO_CONTAINER_ID sh -c "grep -P 'Starting' $LOG_FILE || true;"
    # docker exec $ODOO_CONTAINER_ID sh -c "cat /var/log/odoo/odoo.log"
}

LINES_FAIL_TEST=$(get_odoo_log)
show_separator "log error here"
echo $LINES_FAIL_TEST
