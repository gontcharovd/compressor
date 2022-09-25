#!/usr/bin/env bash
pg_dump -Fc \
    --host=compressor-data.postgres.database.azure.com \
    --username=gontcharovd \
    --table=pressure \
    --verbose \
    --file=/home/denis/code/compressor/sql/compressor-data.dump \
    postgres 