#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

ODOO_CONTAINER_ID=$(get_odoo_container_id)
show_separator "Start analyzing log file"

function analyze_log {
    # in case Odoo don't have any ERROR -> log file will be not generated
    # so no need to analyze log anymore
    [ -f ${LOG_FILE_OUTSIDE} ]
    if [ $? -ne 0 ]; then
        return 0
    fi

    grep -m 1 -P '^[0-9-\s:,]+ERROR' $LOG_FILE_OUTSIDE
    error_exist=$?
    if [ $error_exist -eq 0 ]; then
        exit 1
    fi
}

analyze_log
