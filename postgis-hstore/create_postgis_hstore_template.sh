#!/bin/bash

# Taken from https://docs.djangoproject.com/en/1.6/_downloads/create_template_postgis-debian.sh
# Added hstore extension

GEOGRAPHY=0
POSTGIS_SQL=postgis.sql

# For Ubuntu 10.04
if [ -d "/usr/share/postgresql/8.4/contrib" ]
then
    POSTGIS_SQL_PATH=/usr/share/postgresql/8.4/contrib
fi

# For Ubuntu 10.10 (with PostGIS 1.5)
if [ -d "/usr/share/postgresql/8.4/contrib/postgis-1.5" ]
then
    POSTGIS_SQL_PATH=/usr/share/postgresql/8.4/contrib/postgis-1.5
    GEOGRAPHY=1
fi

# For Ubuntu 11.10 / Linux Mint 12 (with PostGIS 1.5)
if [ -d "/usr/share/postgresql/9.1/contrib/postgis-1.5" ]
then
    POSTGIS_SQL_PATH=/usr/share/postgresql/9.1/contrib/postgis-1.5
    GEOGRAPHY=1
fi

createdb -E UTF8 template_postgis_hstore && \
( createlang -d template_postgis_hstore -l | grep plpgsql || createlang -d template_postgis plpgsql ) && \
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis_hstore';" && \
psql -d template_postgis_hstore -f $POSTGIS_SQL_PATH/$POSTGIS_SQL && \
psql -d template_postgis_hstore -f $POSTGIS_SQL_PATH/spatial_ref_sys.sql && \
psql -d template_postgis_hstore -c "GRANT ALL ON geometry_columns TO PUBLIC;" && \
psql -d template_postgis_hstore -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

if [ $GEOGRAPHY -eq 1 ]
then
    psql -d template_postgis_hstore -c "GRANT ALL ON geography_columns TO PUBLIC;"
fi

psql -d template_postgis_hstore -c "CREATE EXTENSION hstore;"
