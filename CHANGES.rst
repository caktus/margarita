Margarita
=========

Changes - always add to the top.

v 2.2.1 on April 19, 2017
-------------------------

* BUG FIX: Use explicit paths in the cron command which renews LetsEncrypt certificates. (#155)

v 2.2.0 on February 13, 2017
----------------------------

* Redo LetsEncrypt certificate process using `certbot-auto
  <https://certbot.eff.org/all-instructions/#ubuntu-other-none-of-the-above>`_ (#149, #152)
* Make cert renewal more robust by having certbot restart Nginx after renewal.

v 2.1.1 on February 9, 2017
---------------------------

* The Python DeadSnakes PPA is no more. (#151)

  This change stops trying to install the PPA, which was breaking deploys,
  but doesn't try to find an alternative source for oddball Python versions.

v 2.1.0 on December 15, 2016
----------------------------

* Fix Vagrant support. (#148)


v 2.0.0 on December 15, 2016
----------------------------

* Add support for Ubuntu 16.04 (Xenial)

  .. IMPORTANT::

     To upgrade to this version of Margarita from either a previous release, or from the
     'origin/xenial' branch of this repo, then you will need to follow these steps. Look at the
     `Django Project Template PR
     <https://github.com/caktus/django-project-template/pull/280/files>`_ for a diff that you may be
     able to apply directly to your repo in place of steps 1 through 4:

     1. Copy the latest version of the ``install_salt.sh`` script from the `Django Project Template
        repo <https://github.com/caktus/django-project-template/blob/master/install_salt.sh>`_ to
        your repo.

     #. Set ``SALT_VERSION`` to '2016.3.4' in your fabfile.py.

     #. Add ``network.default_route`` to the ``mine_functions`` section of the ``setup_minion``
        function of your fabfile::

          'mine_functions': {
              'network.interfaces': [],
              'network.default_route': {
                  'family': 'inet',
              },
          },

     #. Update ``margarita_version`` to '2.0.0' in ``conf/pillar/project.sls``

     #. Update your servers::

          fab staging setup_master
          fab staging setup_minion:<INSERT CURRENT ROLES HERE> -H <MINION_IP>
          # repeat the setup_minion call for each minion.
          fab staging deploy

        To find the list of roles for each minion, SSH into the minion and look at /etc/salt/minion



v 1.7.6 on November 2, 2016
---------------------------

* Allow specifying ``letsencrypt_domains`` in Pillar to make `letsencrypt`
  work with multiple domains. Example::

    letsencrypt_domains:
      - example.com
      - www.example.com
      - legacyexample.com
      - www.legacyexample.com

v 1.7.5 on October 27, 2016
---------------------------

* Allow override of Celery worker-specific command-line arguments.  Continues to default to
  "--loglevel=INFO".  Example::

    celery_worker_arguments: "--loglevel=INFO --maxtasksperchild 1"

v 1.7.4 on August 17, 2016
--------------------------

* Always run migrate during deploy. Previously "migrate --list" was used in an attempt to
  only run migrate when needed, but "migrate --list" no longer exists with Django 1.10. The new
  variant, showmigrations, didn't exist in Django 1.7. For now, to allow supporting a wide range
  of Django versions on deploy, it's easiest to simply run migrate on every deploy.

v 1.7.3 on July 1, 2016
-----------------------

* When HTTP Auth is enabled (typically for staging environments) allow OPTIONS through without
  Authorization header, to allow CORS preflight requests to complete.

v 1.7.2 on Jun 24, 2016
-----------------------

* Manually reset letsencrypt git repo since the salt version attempted in 1.7.1 didn't work in
  practice.

v 1.7.1 on May 24, 2016
-----------------------

* Reset the letsencrypt git repo each time before pulling, to avoid an
  error due to a dirty working tree caused by letsencrypt's built-in updater.


v 1.7.0 on May 16, 2016
-----------------------

* Pin global pip to 8.1.1 to avoid Salt incompatibility.

  .. IMPORTANT::

     If your deploy is currently broken because you have run a deploy with a version of Margarita
     less than 1.7.0, then run the following command first::

       $ fab staging salt:"cmd.run 'pip install pip\=\=8.1.1'"   # Yes, the backquotes are needed!

     Then, update your ``margarita_version`` to 1.7.0 and deploy::

       $ fab staging deploy


v 1.6.8 on May 3, 2016
----------------------

* Add a state to install the Postgresql PPA for the desired version of
  Postgres. Previously, the deploy would fail when using a version of
  Postgres that was not available on the system.

v 1.6.7 on Mar 22, 2016
-----------------------

* Allow specifying the branch to deploy in the 'branch' pillar variable.
    - NOTE: These changes are fully backwards compatible; no pillar changes
      are required to update but structure simplifications are now possible.
    - Most projects will be able to specify the repo just once, in `project.sls`::

        repo:
            url: git@github.com/user/project.git

    - Projects which deploy the `master` branch to their production
      environments may only need to change the `branch` pillar in their
      staging environments::

        branch: develop

    - With this structure, the deploy branch can be easily overridden from
      the command line::

        salt '*' -l info highstate pillar='{"branch": "hotfix"}'

      Corresponding changes in caktus/django-project-template show how
      this can be used to deploy a non-default branch using Fabric with no
      need to edit the pillar file.

      For more info, see the Salt documentation:
      https://docs.saltstack.com/en/latest/topics/pillar/#set-pillar-data-at-the-command-line

v 1.6.6 on Mar 21, 2016
-----------------------

* You can now configure which requirements file to use by specifying
  `requirements_file`

v 1.6.5 on Mar 15, 2016
-----------------------

* Change default value for `stopasgroup` to `false` for gunicorn and celery

v 1.6.4 on Mar 3, 2016
----------------------

* Option to use `letsencrypt.org <https://letsencrypt.org>`_ to
  get certificates for sites by setting ``letsencrypt: true``.
  See also `the documentation <http://caktus.github.io/developer-documentation/margarita/states.html#project-web-balancer>`_.

v 1.6.3 on Feb 26, 2016
-----------------------

* Accept spaces in environment variables (#120)

v 1.6.2 on Feb 25, 2016
-----------------------

* Fixes for ``purge_users`` (#116, #118)

v 1.6.1 on Feb 25, 2016
-----------------------

* Added ``redis-master`` state to install Redis server. (#115)

* Added ``postgresql.client`` state to install Postgresql client. (#115)

* If using New Relic, ensure the agent is installed in the virtualenv. (#115)

v 1.6.0 on Feb 25, 2016
---------------------------

* Added ``purge_users`` state to run after all developer keys are installed to
  disable the accounts of any developers who are no longer in that list.

* Added ``python_backport`` as optional pillar to install Python 2.7.9+ from the
  backport PPA https://launchpad.net/~fkrull/+archive/ubuntu/deadsnakes-python2.7.

* Added ``python_headers`` as optional pillar variable for installing packages
  required to build python dependencies.

* Virtualenv will now be rebuilt if the Python version changes or new headers
  are installed.

* Updated ``base`` and ``postgresql`` states to install the list of packages in
  a single command.

* The default ``postgres_version`` has been updated to 9.3.

* The fallback for resetting the locale to UTF-8 has been removed.
  This was deprecated in v1.0.3.


v 1.5.0 on Jan 15, 2016
-----------------------

* Added a state (``watchlog``) that allows you to forward any plain text log to syslog.

* Don't run ``apt-get update`` on every package install, speeding up deploys.

* Don't install NewRelic plugin unless we have a NewRelic key.

* Fix NPM state and include it so that salt runs it.


v 1.4.0 on Jan 8, 2016
----------------------

* Ensure official Ubuntu npm and nodejs-legacy packages are removed

* Configure a third party PPA as source for NodeJS 4.2 (includes NPM)

* Adds npm_installs state which runs before collectstatic to install
  and update NPM packages

* Adds npm_run_build state which runs after npm_installs and runs a
  configured npm script in the project's package.json named "build",
  expected to run any frontend build process required before
  collectstatic can be run.

Upgrade notes from 1.3.0:

.. WARNING:: Do not use 1.4.0. Follow these instructions, but use 1.5.0 to get
             a critical bugfix.

In order to upgrade to Margarita 1.4.0 you will need a package.json in
your project. For gulpified projects this is where you define frontend
packages and your frontend build process. For legacy projects, you may
move to 1.4.0 by including the following package.json as a placeholder::

  {
    "name": "",
    "version": "0.0.0",
    "description": "",
    "main": "",
    "engines" : {
      "node" : ">=4.2 <4.3"
    },
    "scripts": {
      "build": "true"
    },
    "author": "",
    "license": "",
    "dependencies": {},
    "devDependencies": {}
  }

v 1.3.0 on Jan 6, 2016
----------------------

* Add state `unattended_upgrades` that will run unattended security upgrades
  automatically. See the top of `unattended_upgrades/init.sls` for configuration,
  then add to the base states in your `top.sls` to enable. (#92, #93)
  Results will go to syslog. For now, they'll also be emailed, but we plan
  to remove that once we are confident we have good queries for upgrade
  problems in the logs.

* Install a more recent Erlang than Ubuntu 12.04 has, that is required
  by the latest rabbitmq server.  (#89, #90).

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
