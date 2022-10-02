#!/usr/bin/env bash
export $(grep -v '^#' secrets.env | xargs -0)
pg_restore \
    --host=postgresdatabase7cwkv6diblxjy.postgres.database.azure.com \
    --dbname=postgres \
    --username=gontcharovd \
    --verbose \
    --clean \
    --if-exists \
    /home/denis/code/compressor/sql/compressor-data.dump