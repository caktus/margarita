Margarita
=======================================

This repository hold a collection of states and modules for deployments using
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

* If this release is ready to be used by new projects based on our [project
  template](https://github.com/caktus/django-project-template), then be sure
  to `update this tag
  <https://github.com/caktus/django-project-template/blob/master/conf/salt/margarita.sls#L8>`_
