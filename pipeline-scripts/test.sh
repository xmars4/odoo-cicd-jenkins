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
        return
    fi

    docker exec $ODOO_CONTAINER_ID sh -c "grep -m 1 -P '^[0-9-\s:,]+ERROR' $LOG_FILE"
    return $?
}

function send_file_to_telegram (
    curl --request POST \
     --url https://api.telegram.org/bottoken/sendDocument \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "document": "Required",
  "caption": "Optional",
  "disable_notification": false,
  "reply_to_message_id": null
}
'
)

function send_error_notice_to_dev {
    analyze_log_result=$(analyze_log)
    if [ $analyze_log_result eq 0 ]; then
        echo 'send log file to user here'
    fi
}

send_error_notice_to_dev
