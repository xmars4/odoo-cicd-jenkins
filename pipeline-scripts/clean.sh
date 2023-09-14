#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "Cleaning"

cd $ODOO_WORKSPACE
docker compose down -v
docker compose ps
