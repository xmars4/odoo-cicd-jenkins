#!/bin/bash
docker ps -a
./odoo-docker/scripts/wait-for-it.sh localhost:15430 -t 30


