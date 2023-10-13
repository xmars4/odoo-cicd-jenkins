#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "Cleaning"

cd $ODOO_WORKSPACE
docker compose down -v
rm -rf $LOG_FILE_OUTSIDE