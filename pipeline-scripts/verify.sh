#!/bin/bash
source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "Verify required tools in Jenkins"

docker ps -n 1
docker compose version
curl -V
