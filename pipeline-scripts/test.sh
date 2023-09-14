#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
cd $ODOO_WORKSPACE

function get_odoo_container_id {
    docker-compose ps -q |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${ODOO_IMAGE_TAG}" '$2 == img {print $1}'
}

ODOO_CONTAINER_ID=$(get_odoo_container_id)

echo $ODOO_CONTAINER_ID
