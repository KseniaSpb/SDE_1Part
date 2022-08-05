#!/bin/bash

docker pull postgres
docker run --name postgres1 --rm -e POSTGRES_USER=######## -e POSTGRES_PASSWORD=######## -e POSTGRES_DB=demo -e PGDATA=/var/lib/postgresql/data/pgdata -v $(pwd)/sql:/var/lib/postgresql/data -d -it postgres
sleep 10
docker exec postgres1 psql -U test_sde -d demo -f /var/lib/postgresql/data/init_db/demo.sql



