#!/bin/bash
source "${PIPELINE_UTILS_SCRIPT_PATH}"
received_backup_file_path=$1

populate_variables() {
    declare -g docker_compose_path="$ODOO_DOCKER_COMPOSE_PATH"
    declare -g db_name="postgres"
    declare -g integration_db_name="${ODOO_TEST_DATABASE_NAME}_integration"
    declare -g odoo_image_tag="$ODOO_IMAGE_TAG"
    declare -g odoo_container_store_backup_folder="/tmp/odoo/restore"
    declare -g extracted_backup_folder=$(echo $remote_backup_file_path | sed "s/.tar.gz//")

    declare -g db_host=$(get_config_value "db_host")
    declare -g db_host=${db_host:-'db'}
    declare -g db_port=$(get_config_value "db_port")
    declare -g db_port=${db_port:-'5432'}
    declare -g db_user=$(get_config_value "db_user")
    declare -g db_password=$(get_config_value "db_password")
    declare -g data_dir=$(get_config_value "data_dir")
    declare -g data_dir=${data_dir:-'/var/lib/odoo'}
}

copy_backup() {
    odoo_container_id=$(get_odoo_container_id)
    ls -lah
    pwd
    echo $odoo_container_id
    echo $remote_backup_file_path
    cd $ODOO_DOCKER_COMPOSE_PATH && docker compose ps -a && docker compose config && docker compose ps -a
    echo "========================="
    received_backup_file_name=$(basename $received_backup_file_path)
    docker cp "$received_backup_file_path" $odoo_container_id:$odoo_container_store_backup_folder
    docker_odoo_exec "cd $odoo_container_store_backup_folder && tar -xzf $received_backup_file_name"
}

config_psql_without_password() {
    pgpass_path="~/.pgpass"
    docker_odoo_exec "touch $pgpass_path ; echo $db_host:$db_port:\"$db_name\":$db_user:$db_password > $pgpass_path ; chmod 0600 $pgpass_path"
}

create_empty_db() {
    docker_odoo_exec "psql -h \"$db_host\" -U $db_user postgres \"CREATE DATABASE '${integration_db_name}' ENCODING 'unicode' LC_COLLATE 'C' TEMPLATE 'template0';\""
}

restore_db() {
    sql_dump_path="${odoo_container_store_backup_folder}/${extracted_backup_folder}/dump.sql"
    docker_odoo_exec "psql -h \"$db_host\" -U $db_user $integration_db_name < $sql_dump_path"
}

restore_filestore() {
    backup_filestore_path="${odoo_container_store_backup_folder}/${extracted_backup_folder}/filestore.tar.gz"
    filestore_path="$data_dir/filestore"
    docker_odoo_exec "[ ! -d $filestore_path ] && mkdir $filestore_path && cp $backup_filestore_path $filestore_path && cd $file_store_path &&"tar -xzf filestore.tar.gz
}

restore_backup() {
    copy_backup
    # config_psql_without_password
    # create_empty_db
    # restore_db
    # restore_filestore
}

run_test_cases() {
    #todo
    echo 1
}

analyze_log_file() {
    #todo
    echo 1
}

main() {
    restore_backup
    run_test_cases
    analyze_log_file
}

main
