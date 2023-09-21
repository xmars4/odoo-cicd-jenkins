#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"

ssh "${server_username}"@"${server_host}" -i $server_privatekey 'ls -lah /opt'
