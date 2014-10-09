#!/bin/sh
# Reset the locale if not UTF8
UTF8=$(psql template1 -c 'SHOW SERVER_ENCODING' | grep -c "UTF8")
if [ "$UTF8" != "1" ]; then
    VERSION=$(psql -A -t -c "show server_version" | cut -d. -f1,2)
    echo Stoping $VERSION cluster
    pg_ctlcluster --force $VERSION main stop
    echo Dropping $VERSION cluster
    pg_dropcluster $VERSION main
    echo Starting $VERSION cluster
    pg_ctlcluster $VERSION main start
fi
