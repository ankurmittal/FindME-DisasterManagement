#!/bin/sh

dbname="facedb.litedb";
schema_script="create_schema.sql"

sqlite3 "$dbname" < "${schema_script}"
