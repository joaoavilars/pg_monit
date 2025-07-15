#!/bin/bash
set -e
CONF_FILE="$1"
source "$CONF_FILE"
SQL="SELECT json_build_object('data', json_agg(json_build_object('{#DBNAME}', datname))) FROM pg_database WHERE datname NOT IN ('template0', 'template1', 'postgres');"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_INITIAL" -t -c "$SQL"