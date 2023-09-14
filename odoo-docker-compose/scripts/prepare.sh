#!/bin/bash


docker network inspect odoo-cicd-net >/dev/null 2>&1 || \
    docker network create --driver bridge odoo-cicd-net
