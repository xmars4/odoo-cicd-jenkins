#!/bin/bash

cd ./odoo-docker-compose
cd dockerfile && docker build -t xmars/odoo16-cicd .
docker compose up -d --wait --no-color
docker compose ps