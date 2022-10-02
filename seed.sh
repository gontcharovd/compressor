
#!/usr/bin/env bash
export $(grep -v '^#' secrets.env | xargs -0)

psql \
    --host=postgresdatabase7cwkv6diblxjy.postgres.database.azure.com \
    --username=gontcharovd \
    --dbname=postgres <<-EOSQL
    CREATE TABLE IF NOT EXISTS public.pressure (
        timestamp TIMESTAMPTZ NOT NULL,
        asset_id BIGINT NOT NULL,
        sensor_name VARCHAR (25) NOT NULL,
        pressure REAL,
        PRIMARY KEY (timestamp, asset_id)
    );
EOSQL