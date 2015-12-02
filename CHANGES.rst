Margarita

Changes - always add to the top.

v 1.2.0 on Dec 2, 2015
----------------------

* Send Nginx, Postgres, and Supervisor logs to syslog instead of
  log files. (#61, #74)

  After upgrading, your local log files from these services won't
  receive any more updates. Look in e.g. ``/var/log/syslog`` instead.

* New state that can be used to forward log messages to a remote
  log server. (#85)
* Fix elasticsearch config to not form ad-hoc clusters. (#86)

v 1.1.1 on Nov 2, 2015
----------------------

* Add `statsd` state to install statsd on a server. (#83)
* Fix for newrelic sysmon not picking up environment from dotenv. (#81, #82)
* Use strong DH group (#62, #79)

v 1.1.0 on Sep 28, 2015
-----------------------

* Remove duplicate specification of env vars (#65)

  Upgrade Note: You must have installed and configured dotenv before upgrading
  your project repo to use this version of Margarita. See
  https://github.com/caktus/django-project-template/pull/208 for examples on
  code that you need to add for wsgi and celery processes.

* Set env var ``DOMAIN`` to contain the site's domain (from the Pillar). Remove
  the env var ``ALLOWED_HOSTS`` which was previously holding that information.

  Deprecation Note: Change any references to the ``ALLOWED_HOSTS`` env var to
  instead be ``DOMAIN``. The most likely location where this is being used is
  in the Django settings::

    ALLOWED_HOSTS = os.environ['ALLOWED_HOSTS'].split(';')

  should be changed to::

    ALLOWED_HOSTS = [os.environ['DOMAIN']]



v 1.0.11 on Sep 18, 2015
------------------------

* Fix for New Relic Elasticsearch monitoring

v 1.0.10 on Sep 18, 2015
------------------------

* Add support for monitoring Elasticsearch with New Relic

v 1.0.9 on Sep 17, 2015
-----------------------

* Symlink lessc to /usr/bin where gunicorn can find it (#76)

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
