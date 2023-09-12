#!/bin/bash
docker ps -a
./odoo-docker/scripts/wait-for-it.sh localhost:15430 -t 30
which psql
cat /etc/os-release
psql -h localhost:15430 -U odoo
ls -lah /
echo $POSTGRES_DB $POSTGRES_PASSWORD
psql -U odoo

