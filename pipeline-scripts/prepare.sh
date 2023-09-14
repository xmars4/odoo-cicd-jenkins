#!/bin/bash

function show_separator {
    x="==============================================="
    separator=($x $x "$1" $x $x)
    printf "%s\n" "${separator[@]}"
}

show_separator "Verify tooling"
docker -v
docker compose version
curl -V
