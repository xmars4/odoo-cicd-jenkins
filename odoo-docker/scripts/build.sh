#!/bin/bash

cd ./odoo-docker
pwd
ls -lah

docker compose up -f odoo-docker/docker-compose.yml -d
docker compose ps -a
ls -lah logs
ls -lah .