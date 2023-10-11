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
        return 0
    fi

    docker exec $ODOO_CONTAINER_ID sh -c "grep -m 1 -P '^[0-9-\s:,]+ERROR' $LOG_FILE"
    error_exist=$?
    docker exec $ODOO_CONTAINER_ID sh -c "cat $LOG_FILE"

    echo "last result of unit test --- $?"

    if [ $error_exist -eq 0 ]; then
        # we copied the log file to Jenkins instance so we can send it to Telegram
        echo "we copied the log file to Jenkins instance so we can send it to Telegram"
        echo 'do u go here'
        cat $LOG_FILE_OUTSIDE
        rm -rf $LOG_FILE_OUTSIDE
        docker cp $ODOO_CONTAINER_ID:$LOG_FILE $LOG_FILE_OUTSIDE
        exit 1
    fi
}

analyze_log
