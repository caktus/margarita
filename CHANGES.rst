Margarita

Changes - always add to the top.

v 1.0.3 on Jul 27, 2015
-----------------------
* Replace configure_utf-8.sh with a no-op command.

  Deprecation Note: Remove any spots which ``require`` the script above. Grep
  for "``- cmd: /var/lib/postgresql/configure_utf-8.sh``" and remove them. The
  no-op script will be removed during a future release.

v1.0.2 on Jul 3, 2015
----------------------
* Nginx fixes: require nginx to be installed, and before we try to
  edit its config file.

v1.0.1 on June 22, 2015
-----------------------

* Only install one version of Postgres
* Don't need to create a new PG cluster in order to get UTF-8
  if Postgres is 9.3 or later.

v1.0.0 on June 18, 2015
-----------------------

* Beginning of versioning for Margarita.
