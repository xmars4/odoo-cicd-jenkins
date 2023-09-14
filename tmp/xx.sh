#!/bin/bash

function get_list_addons {
    if [[ $# -gt 0 ]]; then
        cd "$1"
    fi
    find . -maxdepth 1 -mindepth 1 -not -path '*/\.*' -type d -printf "%f,"
}

x=$(get_list_addons "/home/xmars/dev/odoo-projects/sotatek-scs/custom-addons")
echo $x
