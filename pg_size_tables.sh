#!/bin/bash
set -e
CONF_FILE="$1"
DB_TO_CHECK="$2"
source "$CONF_FILE"
SQL="SELECT json_build_object('data', json_agg(json_build_object('{#TABLENAME}', relname, '{#TABLESIZE}', pg_table_size(C.oid), '{#INDEXSIZE}', pg_indexes_size(C.oid), '{#TOTALSIZE}', pg_total_relation_size(C.oid)))) FROM (SELECT C.oid, C.relname FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema') AND C.relkind = 'r' AND nspname !~ '^pg_toast') AS C;"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_TO_CHECK" -t -c "$SQL"