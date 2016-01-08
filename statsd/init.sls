# Install statsd and provide basic default configuration
# See: https://www.digitalocean.com/community/tutorials/how-to-configure-statsd-to-collect-arbitrary-stats-for-graphite-on-ubuntu-14-04
include:
  - nodejs
  - version-control

statsd_prereqs:
  pkg.latest:
    - pkgs:
        - devscripts
        - debhelper
    - require:
      - pkg: nodejs
      - pkg: git-core

install_statsd:
  cmd.script:
    - source: salt://statsd/install_statsd.sh
    - creates: /usr/share/statsd/stats.js
    - user: root
    - require:
      - pkg: statsd_prereqs

statsd_config:
  file.managed:
    - name: /etc/statsd/localConfig.js
    - source: salt://statsd/localConfig.jsconfig
    - require:
      - cmd: install_statsd

statsd_service:
  service.running:
    - name: statsd
    - enable: true
