#!/bin/bash
export CURRENT_UID=$(id -u):$(id -g)

# make database's container folder if not exists

mkdir -p database

# deploy

docker-compose -f docker-compose-db-only.yml build && docker-compose -f docker-compose-db-only.yml up
# docker-compose -f docker-compose-full.yml build && docker-compose -f docker-compose-full.yml up