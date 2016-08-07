Margarita
=======================================

This repository holds a collection of states and modules for deployments using
`SaltStack <http://saltstack.com/>`_. These exist primarily to support the
`Caktus Django project template <https://github.com/caktus/django-project-template>`_.


License
--------------------------------------

These states are released under the BSD License. See the
`LICENSE <https://github.com/caktus/margarita/blob/master/LICENSE>`_ file for more details.


Contributing
--------------------------------------

If you think you've found a bug or are interested in contributing to this project
check out `margarita on Github <https://github.com/caktus/margarita>`_.

Development sponsored by `Caktus Consulting Group, LLC
<http://www.caktusgroup.com/services>`_.


Versions
--------------------------------------

See the CHANGES.rst file for a list of changes in each version of Margarita
since we started applying version numbers.  The version number in the top
entry is the version of Margarita that you're looking at; it's not stored
anywhere else for now.

To make a new release:

* Install `git flow <https://github.com/nvie/gitflow/wiki/Installation>`_
  if you don't have it already.  (Hint: ``apt-get install git-flow`` or
  ``brew install git-flow``.)
* Run ``git flow init -d`` in your local working tree if you haven't before.
* Make sure you have no local uncommited changes
* Make sure you have the latest master & develop branches locally (pull both)::

    git checkout master
    git pull origin master
    git checkout develop
    git pull origin develop

* Run "git flow release start X.Y.Z" where X.Y.Z is the new version number.
* Edit CHANGES.rst with the new version number and the changes since the last
  release. Pay special attention to documenting any changes that could break
  projects using older versions of Margarita.
* Commit those changes.
* Run "git flow release finish -Fp -m X.Y.Z X.Y.Z" and follow the instructions.
* Push both develop & master with tags::

    git checkout master
    git push origin master --tags
    git checkout develop
    git push origin develop --tags

* If this release is ready to be used by new projects based on our `project
  template <https://github.com/caktus/django-project-template>`_, then be sure
  to `update this tag
  <https://github.com/caktus/django-project-template/blob/master/conf/salt/margarita.sls#L8>`_


Variables
---------

The following variables are expected to be defined in the
Salt pillar when using Margarita's Salt states.

domain
    The public domain name of the instance, e.g. "mysite.example.com".
env
    If provided, this should be a dictionary. Each key-value in it will
    be added as an environment variable when running the Django processes
    (e.g. Gunicorn, celery workers).
environment
    E.g. 'production', 'staging', or 'local'.
github_deploy_key
    Optional ssh private key to use when talking to github.
http_auth
    If specified, apply HTTP Basic Auth to the site.  Username and password
    should be PGP encrypted (see docs).  Example::

        http_auth:
           username: |-
            -----BEGIN PGP MESSAGE-----
            -----END PGP MESSAGE-----
           password: |-
            -----BEGIN PGP MESSAGE-----
            -----END PGP MESSAGE-----

less_version
    What version of Less (the CSS compiler) to use.
postgres_version
    Version of postgres to install.  E.g. '9.3'
project_name
    Name of the project. Must be a valid identifier, so make it lowercase
    and no spaces or punctuation other than underscore.
python_version
    What version of Python the project uses, e.g. "2.7" or "3.4".
repo
    Where to get the project code.  ``url`` should be a URL in the format you'd use
    with ``git clone``, like ``git@github.com:CHANGEME/CHANGEME.git``
    or ``https://github.com/CHANGEME/CHANGEME.git``.  ``branch`` should be
    a branch name, tag name, or revision::

      repo:
        url: git@github.com:CHANGEME/CHANGEME.git
        branch: master

secrets
    Mostly just like ``env``. A few specific values are expected to be here;
    see below.
secrets.BROKER_PASSWORD
    Password to assign to the Rabbitmq user (which is always named
    ``{{ project_name }}_{{ environment }}``).
secrets.DB_PASSWORD
    Password to assign to the Postgres user.  (The user and datebase are always named
    ``{{ project_name }}_{{ environment }}``.)
ssl_cert
    If ssl_key and ssl_cert are specified, use this key/cert. Otherwise,
    generate a self-signed one.
ssl_key
    If ssl_key and ssl_cert are specified, use this key/cert. Otherwise,
    generate a self-signed one.
users
    This should be a list of developer users and their public SSH keys, to define on the servers.
    Example::

      users:
         example-user:
           public_key:
             - ssh-dss AAAAB3NzaC1kc3MAAACBAP/dCNcAJED+pBsEwH01E4NU2xrvoB6H5gXkvQHWIKUuMF3MWXgSGhKpgVqLJKh+d0gwuKyI9344HM5dFs4z3E0JhI7Fg4uXIYu1SwuqnxO+D18WLVGt4gCn57JCjLy/c8LJWAHJWFb2v9t4fayC+oBiyEvpjI6VYIJnSvO3D4tjAAAAFQCNzcKi0sehN1Jw+zB6ccMlHt5E6wAAAIEAnW18UHG/O+RIkJazTJ7qFlOb79RS1nnvnHAvtfuiAPIBmeJcKoZkiQzeBYtFereSRHmSug9DsqHK6C5PrP36UMZYhDkqqp5gpJexmokI2kt3AVxJwro7cjy6Tq+0yt+lwqH4JEblybk7yPeRNC1ihnp2CSipC5LP1PydIcgN9/UAAACAeH1OxUzgCfpM06cfKL57gtjIS34ryCdkT2oYfYOANa8vahN2JqxB004o+z2CnQ9DkTqzzf9jUYI/qal19+zYhn8Bd/FdPVp+VTfRpR17fQKuTWrnF7g6jNVN2ltwHo6o99vrCzjHhJHZ2EXOODzAUrACptyfQv/ZCutkjAg44YE= copelco@montgomery.local
         example2:
           public_key:
             - ssh-dss AAAAB3NzaC1kc3MAAACBAP/dCNcAJED+pBsEwH01E4NU2xrvoB6H5gXkvQHWIKUuMF3MWXgSGhKpgVqLJKh+d0gwuKyI9344HM5dFs4z3E0JhI7Fg4uXIYu1SwuqnxO+D18WLVGt4gCn57JCjLy/c8LJWAHJWFb2v9t4fayC+oBiyEvpjI6VYIJnSvO3D4tjAAAAFQCNzcKi0sehN1Jw+zB6ccMlHt5E6wAAAIEAnW18UHG/O+RIkJazTJ7qFlOb79RS1nnvnHAvtfuiAPIBmeJcKoZkiQzeBYtFereSRHmSug9DsqHK6C5PrP36UMZYhDkqqp5gpJexmokI2kt3AVxJwro7cjy6Tq+0yt+lwqH4JEblybk7yPeRNC1ihnp2CSipC5LP1PydIcgN9/UAAACAeH1OxUzgCfpM06cfKL57gtjIS34ryCdkT2oYfYOANa8vahN2JqxB004o+z2CnQ9DkTqzzf9jUYI/qal19+zYhn8Bd/FdPVp+VTfRpR17fQKuTWrnF7g6jNVN2ltwHo6o99vrCzjHhJHZ2EXOODzAUrACptyfQv/ZCutkjAg44YE= copelco@montgomery.local

There are lots of optional things. For example, look at the code in ``project/db/postgresql.conf``
to see all the postgres tuning parameters that can be overridden by setting variables
in pillar.


New Relic
---------

To enable New Relic monitoring for an environment:

* Get a license key for each environment where you want to use New Relic.
* In pillar, add a variable ``secrets.NEW_RELIC_LICENSE_KEY`` containing the license key
  for each environment (and be sure to encrypt it)::

    # <environment>.sls
    secrets:
        NEW_RELIC_LICENSE_KEY: |-
            -----BEGIN PGP MESSAGE-----
            -----END PGP MESSAGE-----

* Add variables under "env:" for other configuration for the Python agent.
  You probably want at least::

    # project.sls
    env:
        NEW_RELIC_LOG: "/var/log/newrelic/agent.log"
        # Only if your account has high security enabled:
        NEW_RELIC_HIGH_SECURITY: "true"

    # <environment>.sls
    env:
        NEW_RELIC_APP_NAME: myproject <environment>
        NEW_RELIC_MONITOR_MODE: "true" or "false"

  Be sure to quote "true" and "false" as above, to avoid Salt/YAML turning these into
  real Booleans; we want the strings "true" or "false" in the environment.

  You can put some values in ``project.sls`` and others in ``<environment>.sls``.  Just
  be consistent for a given key; if the same key is present in both
  ``project.sls`` and the current ``<environment>.sls`` file, Salt makes no
  guarantees about which value you'll end up with.

  See https://docs.newrelic.com/docs/agents/python-agent/installation-configuration/python-agent-configuration#environment-variables
  for a list of things you can configure this way.

  Note that any environment where NEW_RELIC_LICENSE_KEY is not set will not
  include any New Relic configuration, so it's safe to put other settings
  in ``project.sls`` even if you're not using New Relic in every environment.

* If you are using elasticsearch and would like New Relic monitoring of that as well,
  add to pillar somewhere::

    # project.sls or <environment>.sls
    elasticsearch_newrelic: true

* Add state ``newrelic_sysmon`` to your Salt ``top.sls`` in the ``base`` section (for all servers).
  It's safe to add that unconditionally for all environments; it's a no-op if no New Relic
  license key has been defined::

    base:
      '*':
        - ...
        - newrelic_sysmon

* Be sure ``newrelic`` is in the Python requirements of the project.


States
------

forward_logs
~~~~~~~~~~~~

Including this state for a host (in ``top.sls``) forwards all syslog messages to another
system.  It requires a ``LOG_DESTINATION`` secret which should have the format `<hostname>:<port>`.
