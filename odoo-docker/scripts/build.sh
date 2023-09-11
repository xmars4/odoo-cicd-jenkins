#!/bin/bash

docker network create odoo-cicd-test

docker compose up -f odoo-docker/docker-compose.yml -d
docker compose ps -a
ls -lah logs
ls -lah .