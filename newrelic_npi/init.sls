# Install New Relic Platform Installer under /usr/share/npi
{% import 'project/_vars.sls' as vars with context %}

{% if vars.use_newrelic %}
{% set version = "0.1.5" %}
{% set tarball = "platform_installer-linux-x64-v" + version + ".tar.gz" %}
{% set url = "https://download.newrelic.com/npi/v" + version + "/" + tarball %}
{% set hash = "sha512=92aaec9ae56abb05bce3663150eddb01425ec8718f17e987a1e7f7c812a3e3fc3a7a217944413f857a5e5ec98b66d7ab6927db9bb981b6f98eee1c860c3c3306" %}

install_npi:
  archive.extracted:
    - name: /usr/share/npi
    - source: {{ url }}
    - source_hash: {{ hash }}
    - if_missing: /usr/share/npi/npi
    - archive_format: tar
    - tar_options: -z --strip-components=1

configure_npi:
  cmd.run:
    - name: ./npi set license_key {{ pillar['secrets']['NEW_RELIC_LICENSE_KEY'] }} && ./npi set user {{ pillar['project_name'] }} && ./npi set distro debian
    - cwd: /usr/share/npi
{% endif %}
