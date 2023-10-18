#!/bin/bash
source "${PIPELINE_UTILS_SCRIPT_PATH}"
show_separator "Verify required tools in Jenkins"

docker ps -n 1
docker compose version
curl -V
