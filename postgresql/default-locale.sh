pg_ctlcluster --force 9.1 main stop
pg_dropcluster 9.1 main
pg_createcluster --start -e UTF-8 9.1 main
