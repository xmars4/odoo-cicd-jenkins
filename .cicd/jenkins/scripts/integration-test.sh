#!/bin/bash

jenkins() {
    populate
}

populate_variables() {
    declare -g odoo_image_tag="xmars/odoo:16"                                                         # odoo image tag - declared in docker compose file
    declare -g docker_compose_path=/home/xmars/dev/odoo-projects/sotatek-scs/custom-addons/.cicd/odoo # path to folder contains docker-compose.yml file - on host machine

    declare -g config_file=/etc/odoo/odoo.conf # inside Odoo container
    declare -g db_host=$(get_config_value "db_host")
    declare -g db_host=${db_host:-'db'}
    declare -g db_port=$(get_config_value "db_port")
    declare -g db_port=${db_port:-'5432'}
    declare -g db_user=$(get_config_value "db_user")
    declare -g db_password=$(get_config_value "db_password")
    declare -g data_dir=$(get_config_value "data_dir")
    declare -g data_dir=${data_dir:-'/var/lib/odoo'}
}

get_odoo_container_id() {
    cd $docker_compose_path
    image_tag=$1
    docker compose ps -q -a |
        xargs docker inspect --format '{{.Id}} {{.Config.Image}}' |
        awk -v img="${image_tag}" '$2 == img {print $1}'
}

execute_command_inside_odoo_container() {
    odoo_container_id=$(get_odoo_container_id $odoo_image_tag)
    if [[ -z $odoo_container_id ]]; then
        echo "There is no running Odoo container with tag name '$odoo_image_tag'"
        exit 1
    fi
    docker exec $odoo_container_id sh -c "$@"
}

restore_db() {
    create_empty_db
}

create_empty_db() {
    # restore to an empty Odoo instance and run test cases for those modules

    docker exec odoo_container sh -c "psql -h "
    docker exec odoo sh -c "CREATE DATABASE \"my-db\" ENCODING 'unicode' LC_COLLATE 'C' TEMPLATE 'template0'"
}

main() {
    populate_variables "$@"
}

main "$@"
