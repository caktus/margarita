{% import 'project/_vars.sls' as vars with context %}
include:
  - project.web.app

# Install NodeJS v4.x, to match local frontend dev setup
nodejs_repo:
  pkgrepo.managed:
    - humanname: NodeSource Node.js PPA
    - name: deb https://deb.nodesource.com/node_4.x {{ grains['lsb_distrib_codename'] }} main
    - file: /etc/apt/sources.list.d/nodesource.list
    - key_url: salt://project/web/nodesource.pub
    - require_in:
      - pkg: nodejs

nodejs:
  pkg.removed:
    - name: npm
    - name: nodejs-legacy
  pkg.latest:
    - name: nodejs
