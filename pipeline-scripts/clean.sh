#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "Cleaning"

cd $odoo_workspace
docker compose down -v
docker compose ps
