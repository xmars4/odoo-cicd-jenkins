#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

ODOO_CONTAINER_ID=$(get_odoo_container_id)
show_separator "Start analyzing log file"

function analyze_log {
    # in case Odoo don't have any ERROR -> log file will be not generated
    # so no need to analyze log anymore
    docker exec $ODOO_CONTAINER_ID sh -c "[ -f ${LOG_FILE} ]"
    if [ $? != 0 ]; then
        return 1
    fi

    docker exec $ODOO_CONTAINER_ID sh -c "grep -m 1 -P '^[0-9-\s:,]+ERROR' $LOG_FILE"
    return $?
}

function send_error_notice_to_dev {
    analyze_log_result=$(analyze_log)
    show_separator "your result here ${analyze_log_result}"
    if [ "$analyze_log_result" -eq 0 ]; then
        send_message $TELEGRAM_BOT_TOKEN $TELEGRAM_CHANNEL_ID "ez bro, i got it after first tried"
    fi
}

send_error_notice_to_dev
