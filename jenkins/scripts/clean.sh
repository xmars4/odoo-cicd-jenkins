#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
show_separator "Cleaning"

cd $ODOO_WORKSPACE
docker compose down -v
rm -rf $LOG_FILE_OUTSIDE
