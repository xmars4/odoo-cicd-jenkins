#!/bin/bash
docker ps -a
docker logs ${c.id}
./odoo-docker/scripts/wait-for-it.sh localhost:15430 -t 30
which psql
psql -h localhost:15430 -U odoo
// while !</dev/tcp/db/5432; do sleep 1; done;
ls -lah /
echo $POSTGRES_DB $POSTGRES_PASSWORD
psql -U odoo
