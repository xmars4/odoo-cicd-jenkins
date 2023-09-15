#!/bin/bash

# declare all useful functions here
function show_separator {
    x="==============================================="
    separator=($x $x "$1" $x $x)
    printf "%s\n" "${separator[@]}"
}

function get_odoo_container_id {
    docker compose ps -q |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${ODOO_IMAGE_TAG}" '$2 == img {print $1}'
}

ODOO_WORKSPACE="${WORKSPACE}/odoo-docker-compose"
ODOO_IMAGE_TAG="xmars/odoo16-cicd"
EXTRA_ADDONS_PATH="${ODOO_WORKSPACE}/extra-addons"
CONFIG_FILE="${ODOO_WORKSPACE}/etc/odoo.conf"
LOG_FILE="/var/log/odoo/odoo.log"
