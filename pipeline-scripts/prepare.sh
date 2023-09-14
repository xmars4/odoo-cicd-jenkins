#!/bin/bash
source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "Verify tooling"

docker -v
docker compose version
curl -V
