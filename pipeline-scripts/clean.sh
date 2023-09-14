#!/bin/bash

cd ./odoo-docker-compose
docker compose down --remove-orphan -v
docker compose ps