pg_ctlcluster --force {{ version }} main stop
pg_dropcluster {{ version }} main
pg_createcluster --start -e UTF-8 {{ version }} main
