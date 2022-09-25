#!/usr/bin/env bash

pg_dump \
    --host=compressor-data.postgres.database.azure.com \
    --username=gontcharovd \
    --table=pressure \
    --verbose \
    --file=/home/denis/code/compressor/compressor-data-dump.sql \
    postgres 