#!/bin/bash
source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "Verify tooling of Jenkins"

check_required_tools() {
    docker ps -n 1
    docker compose version
    curl -V
}

check_required_tools >/dev/null
