#!/bin/bash
source "${PIPELINE_UTILS_SCRIPT_PATH}"
received_backup_file_path=$1

populate_variables() {
    declare -g docker_compose_path="$ODOO_DOCKER_COMPOSE_PATH"
    declare -g db_name="postgres"
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

function update_config_file_before_restoration {
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    sed -i "s/^\s*db_name\s*.*//g" $CONFIG_FILE
}

function update_config_file_after_restoration {
    custom_addons=$(get_list_addons "$ODOO_CUSTOM_ADDONS_PATH")
    sed -i "s/^\s*command\s*.*//g" $CONFIG_FILE
    echo -e "\ncommand = --stop-after-init --workers 0 --database $ODOO_TEST_DATABASE_NAME --logfile "$LOG_FILE" --log-level info -i "${custom_addons}" --test-enable --test-tags "${custom_addons}"\n" >>$CONFIG_FILE
}

copy_backup() {
    odoo_container_id=$(get_odoo_container_id)
    ls -lah
    pwd
    echo $odoo_container_id
    echo $remote_backup_file_path
    docker_compose ps -a
    echo "========================="
    received_backup_file_name=$(basename $received_backup_file_path)
    docker_odoo_exec "mkdir -p $odoo_container_store_backup_folder"
    docker cp "$received_backup_file_path" $odoo_container_id:$odoo_container_store_backup_folder
    docker_odoo_exec "cd $odoo_container_store_backup_folder && tar -xzf $received_backup_file_name"
}

config_psql_without_password() {
    pgpass_path="~/.pgpass"
    docker_odoo_exec "touch $pgpass_path ; echo $db_host:$db_port:\"$db_name\":$db_user:$db_password > $pgpass_path ; chmod 0600 $pgpass_path"
}

start_instance() {
    update_config_file_before_restoration
    docker_compose down -v # remove old test instance
    docker_compose up -d
}

restart_instance() {
    update_config_file_after_restoration
    docker_compose restart
}

create_empty_db() {
    docker_odoo_exec "psql -h \"$db_host\" -U $db_user postgres \"CREATE DATABASE '${ODOO_TEST_DATABASE_NAME}' ENCODING 'unicode' LC_COLLATE 'C' TEMPLATE 'template0';\""
}

restore_db() {
    sql_dump_path="${odoo_container_store_backup_folder}/${extracted_backup_folder}/dump.sql"
    docker_odoo_exec "psql -h \"$db_host\" -U $db_user $ODOO_TEST_DATABASE_NAME < $sql_dump_path"
}

restore_filestore() {
    backup_filestore_path="${odoo_container_store_backup_folder}/${extracted_backup_folder}/filestore.tar.gz"
    filestore_path="$data_dir/filestore"
    docker_odoo_exec "[ ! -d $filestore_path ] && mkdir $filestore_path && cp $backup_filestore_path $filestore_path && cd $file_store_path &&"tar -xzf filestore.tar.gz
}

restore_backup() {
    start_instance
    copy_backup
    # config_psql_without_password
    # create_empty_db
    # restore_db
    # restore_filestore
    # restart_instance
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
