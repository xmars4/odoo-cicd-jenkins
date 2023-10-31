#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"
show_separator "Cleaning"

docker_compose_clean
