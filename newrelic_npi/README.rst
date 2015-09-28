New Relic NPI
=============

NPI is the `New Relic Platform Installer <https://docs.newrelic.com/docs/plugins/plugins-new-relic/installing-plugins/installing-npi-compatible-plugin>`_
that can be used to easily install compatible plugins.

This state will create a ``/usr/share/npi`` directory and install NPI into it.

If you want to install an NPI compatible plugin, include this state in
your own state file::

    include:
    - newrelic_npi

Then see the ``elasticsearch/init.sls`` file for an example of the rather convoluted
way to use it to install a New Relic plugin.  (Anyone want to write an NPI state for
Salt?)
