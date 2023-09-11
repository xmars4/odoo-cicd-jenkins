#!/bin/bash

cd ./odoo-docker
pwd
ls -lah
echo "wtf happen"
docker compose up -d
docker compose ps -a