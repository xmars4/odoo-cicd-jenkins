#!/bin/bash

# ==============================================================================
# ================= Execute these functions on SERVER ==========================
# =============================================================================

main() {
    populate_variables "$@"
    check_required_files
    backup_file_path=$(create_backup_inside_container)
    copy_backup_to_host $backup_file_path
    delete_old_backup_files
}

populate_variables() {
    declare -g docker_compose_path="$1"        # path to folder contains docker-compose.yml file - on host machine
    declare -g db_name="$2"                    # supplied by jenkins pipeline - config manually in pipeline
    declare -g odoo_image_tag="$3"             # odoo image tag - declared in docker compose file
    declare -g config_file=/etc/odoo/odoo.conf # path inside the Odoo container
    declare -g backup_folder=/tmp/backup       # path inside the Odoo container

    declare -g db_host=$(get_config_value "db_host")
    declare -g db_host=${db_host:-'db'}
    declare -g db_port=$(get_config_value "db_port")
    declare -g db_port=${db_port:-'5432'}
    declare -g db_user=$(get_config_value "db_user")
    declare -g db_password=$(get_config_value "db_password")
    declare -g data_dir=$(get_config_value "data_dir")
    declare -g data_dir=${data_dir:-'/var/lib/odoo'}
    declare -g DATE_FORMAT="%Y-%m-%d_%H-%M-%S"
}

check_required_files() {
    if [[ ! -d $docker_compose_path ]]; then
        echo "Docker compose path '$docker_compose_path' does not exist on host machine"
        exit 1
    fi

    execute_command_inside_odoo_container "[ ! -f $config_file ]"
    if [[ $? == 0 ]]; then
        echo "Config file in '$config_file' path does not exist on Odoo container"
        exit 1
    fi
}

get_config_value() {
    param=$1
    execute_command_inside_odoo_container "grep -q -E \"^\s*\b${param}\b\s*=\" \"$config_file\""
    if [[ $? == 0 ]]; then
        value=$(execute_command_inside_odoo_container "grep -E \"^\s*\b${param}\b\s*=\" \"$config_file\" | cut -d \" \" -f3 | sed 's/[\"\n\r]//g'")
    fi
    echo "$value"
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

should_we_generate_new_backup() {
    latest_backup_file_creation_timestamp=$1
    current_timestamp=$(execute_command_inside_odoo_container "date -u +%s")
    different=$((current_timestamp - latest_backup_file_creation_timestamp))
    # we should get a new backup file every 1 hour
    if [[ $different -gt '3600' ]]; then
        echo "true"
    else
        echo "false"
    fi
}

convert_datetime_string_to_timestamp() {
    date_string=$1 # in format : $DATE_FORMAT
    valid_date_string=$(echo $date_string | sed "s/-/\//; s/-/\//; s/_/ /; s/-/:/; s/-/:/")
    echo $(date -u -d "$valid_date_string" "+%s")
}

create_backup_inside_container() {
    # Create sql and filestore backup inside the Odoo container
    # backup folder contains .tar.gz files
    # a .tar.gz file contains:
    #   - dump.sql : Oodo database dump
    #   - filestore.tar.gz: Odoo filestore
    latest_backup_tar_file=$(get_latest_backup_tar_file)
    latest_backup_tar_file_path="$backup_folder/$latest_backup_tar_file"
    create_new_backup="false"
    if [ -n "$latest_backup_tar_file" ]; then
        creation_date=$(echo $latest_backup_tar_file | sed "s/^${db_name}_//; s/\.tar.gz//")
        timestamp=$(convert_datetime_string_to_timestamp "$creation_date")
        create_new_backup=$(should_we_generate_new_backup $timestamp)
    else
        create_new_backup="true"
    fi

    if [[ $create_new_backup == "true" ]]; then
        sub_backup_folder=$(create_sub_backup_folder)
        create_sql_backup $sub_backup_folder
        create_filestore_backup $sub_backup_folder
        new_backup_tar_file_path=$(create_tar_file_backup $sub_backup_folder)
        echo $new_backup_tar_file_path
    else
        echo $latest_backup_tar_file_path
    fi
}

copy_backup_to_host() {
    backup_file_path=$1
    odoo_container_id=$(get_odoo_container_id $odoo_image_tag)
    [ ! -d "$backup_folder" ] && mkdir -p "$backup_folder"
    rm -rf ${backup_folder}/*
    docker cp $odoo_container_id:$backup_file_path $backup_folder
    echo $backup_file_path
}

get_latest_backup_tar_file() {
    execute_command_inside_odoo_container "[ ! -d \"$backup_folder\" ] && mkdir -p \"$backup_folder\""
    latest_backup_tar_file=$(execute_command_inside_odoo_container "ls -tr \"$backup_folder\" | tail -n 1 | grep -E \"^${db_name}_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.tar.gz$\"")
    echo ${latest_backup_tar_file}
}

create_sub_backup_folder() {
    folder_name=$(execute_command_inside_odoo_container "echo $backup_folder/${db_name}_$(date -u +$DATE_FORMAT)")
    execute_command_inside_odoo_container "mkdir -p \"$folder_name\""
    echo $folder_name
}

create_sql_backup() {
    sub_backup_folder=$1
    sql_file_path="${sub_backup_folder}/dump.sql"
    pgpass_path="~/.pgpass"
    execute_command_inside_odoo_container "touch $pgpass_path ; echo $db_host:$db_port:\"$db_name\":$db_user:$db_password > $pgpass_path ; chmod 0600 $pgpass_path"
    execute_command_inside_odoo_container "pg_dump -h \"$db_host\" -U $db_user --no-owner --file \"$sql_file_path\" \"$db_name\""
}

create_filestore_backup() {
    sub_backup_folder=$1
    file_store_path="$data_dir/filestore/"
    execute_command_inside_odoo_container "cd $file_store_path && tar -czf $sub_backup_folder/filestore.tar.gz $db_name"
}

create_tar_file_backup() {
    sub_backup_folder=$1
    sub_backup_folder_name=$(basename $sub_backup_folder)
    new_backup_tar_file_path="${sub_backup_folder_name}.tar.gz"
    execute_command_inside_odoo_container "cd $sub_backup_folder/.. && tar -czf ${new_backup_tar_file_path} $sub_backup_folder_name && rm -rf $sub_backup_folder_name"
    echo "${backup_folder}/${new_backup_tar_file_path}"
}

delete_old_backup_files() {
    # keep only 7 newest files only and delete other files
    # delete inside container and on host machine
    execute_command_inside_odoo_container "cd $backup_folder && ls -1tr $backup_folder | head -n -7 | xargs -d '\n' rm -rf --"
    cd $backup_folder && ls -1tr $backup_folder | head -n -7 | xargs -d '\n' rm -rf --
}

main "$@"
