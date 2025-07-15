#!/bin/bash
set -e
CONF_FILE="$1"
DB_TO_CHECK="$2"
source "$CONF_FILE"
SQL="SELECT pg_database_size('${DB_TO_CHECK}');"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_INITIAL" -t -c "$SQL"