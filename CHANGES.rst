Margarita

Changes - always add to the top.

v 1.0.8 on Sep 4, 2015
----------------------

* Add state to deploy elasticsearch (#72)
* Note that New Relic high security shouldn't be enabled unless
  the account has it turned on. (#71)

v 1.0.7 on Sep 3, 2015
----------------------

* Fix for bug in new Relic support (#70)

v 1.0.6 on Sep 3, 2015
----------------------

(DO NOT USE, use v1.0.7 instead)

* Add support for New Relic (see README for docs). (#58)

v 1.0.5 on Aug 31, 2015
-----------------------

* Make sure we checkout the source repo before things that depend on it
  being there. (#68)

v 1.0.4 on Aug 17, 2015
-----------------------

* Copy all Salt states except margarita from the django project template
  to this repo, so we can then remove them from the django project template
  and be able to maintain them by updating margarita.  (#56)

* Remove dropcluster (#52)

* Document that after a new Margarita release, the django project template's
  instructions should be updated to point to it.  (#54)

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
