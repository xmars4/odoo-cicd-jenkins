#!/bin/bash

docker compose help
cd ./odoo-docker/

docker compose -f ./odoo-docker/docker-compose.yml up -d