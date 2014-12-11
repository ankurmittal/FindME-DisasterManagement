#!/bin/sh

dbdir="../db"
mkdir -p "${dbdir}"
dbname="${dbdir}/facedb.litedb"
schema_script="create_schema.sql"

sqlite3 "$dbname" < "${schema_script}"
