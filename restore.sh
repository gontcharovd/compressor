#!/usr/bin/env bash
pg_restore \
    --host=postgresdatabase7cwkv6diblxjy.postgres.database.azure.com \
    --dbname=postgres \
    --username=gontcharovd \
    --verbose \
    /home/denis/code/compressor/sql/compressor-data.dump