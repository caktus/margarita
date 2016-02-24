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

NOTE: We never update the master branch of this repo to avoid causing unexpected upgrade
problems for older projects which are tracking the master branch.

To make a new release:

* Make sure you have no local uncommited changes
* Make sure you have the latest develop branch locally::

    git checkout develop
    git pull origin develop

* Pick a new version number, attempting to follow the guidelines of `Semantic Versioning
  <http://semver.org/>`_.
* Edit CHANGES.rst with the new version number and the changes since the last
  release. Pay special attention to documenting any changes that could break
  projects using older versions of Margarita.
* Commit those changes.
* Tag your commit::

    git tag 'X.Y.Z'

* Push the updated develop branch and the tag::

    git push origin develop --tags

* If this release is ready to be used by new projects based on our `project
  template <https://github.com/caktus/django-project-template>`_, then update ``margarita_version``
  to this new version in `project.sls
  <https://github.com/caktus/django-project-template/blob/master/conf/pillar/project.sls#L10>`_


States and Variables
--------------------

There are multiple variables that can be configured for your project. There are also some optional
states that are not included in every project by default. This `list of states
<https://caktus.github.io/developer-documentation/margarita/states.html>`_ includes documentation
about all of the available states and about which variables are configurable. Those variables would
be `configured in your pillar
<https://caktus.github.io/developer-documentation/margarita/pillar.html>`_.


Enable Additional Services
--------------------------

Configuration of various useful services including Github, New Relic, Papertrail, Travis CI,
Requires.io and BitHound is documented on our `External Services
<https://caktus.github.io/developer-documentation/services/index.html>`_ page.
