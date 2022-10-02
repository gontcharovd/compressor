#!/usr/bin/env bash
export $(grep -v '^#' secrets.env | xargs -0)
pg_dump -Fc \
    --host=compressor-data.postgres.database.azure.com \
    --username=gontcharovd \
    --table=pressure \
    --clean \
    --verbose \
    --file=/home/denis/code/compressor/sql/compressor-data.dump \
    postgres 