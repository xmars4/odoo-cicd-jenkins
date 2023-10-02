#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

ODOO_CONTAINER_ID=$(get_odoo_container_id)
show_separator "Start analyzing log file"

function analyze_log {
    # in case Odoo don't have any ERROR -> log file will be not generated
    # so no need to analyze log anymore
    docker exec $ODOO_CONTAINER_ID sh -c "[ -f ${LOG_FILE} ]"
    # FIXMe: remove below line #14
    docker exec $ODOO_CONTAINER_ID sh -c "cat ${LOG_FILE}"
    if [ $? != 0 ]; then
        return 0
    fi

    docker exec $ODOO_CONTAINER_ID sh -c "grep -m 1 -P '^[0-9-\s:,]+ERROR' $LOG_FILE"
    if [ $? -eq 0 ]; then
        return 1
    fi
    return 0
}

function send_error_notice_to_dev {
    analyze_log
    if [ $? -ne 0 ]; then
        docker cp $ODOO_CONTAINER_ID:/var/log/odoo/odoo.log $ODOO_WORKSPACE/logs/odoo.log
        send_file_telegram $TELEGRAM_BOT_TOKEN $TELEGRAM_CHANNEL_ID $ODOO_WORKSPACE/logs/odoo.log "Something went wrong, please check the log file"
    fi
}

send_error_notice_to_dev
