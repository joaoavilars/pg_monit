#!/bin/bash
set -e
CONF_FILE="$1"
DB_TO_CHECK="$2"
source "$CONF_FILE"
SQL="SELECT json_build_object('data', json_agg(json_build_object('{#TABLENAME}', relname))) FROM pg_stat_user_tables;"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_TO_CHECK" -t -c "$SQL"