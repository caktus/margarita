# Install NodeJS v4.x, to match local frontend dev setup
nodejs_repo:
  pkgrepo.managed:
    - humanname: NodeSource Node.js PPA
    - name: deb https://deb.nodesource.com/node_4.x {{ grains['lsb_distrib_codename'] }} main
    - file: /etc/apt/sources.list.d/nodesource.list
    - key_url: salt://nodejs/nodesource.pub
    - require_in:
      - pkg: nodejs

# We should use Salt's 'pkg.removed' here, but it has a long-standing bug:
# The state fails if the package isn't installed to begin with.  Sigh.
remove_nodejs_legacy:
  cmd.run:
    - name: apt-get remove npm nodejs-legacy -y

nodejs:
  pkg.latest:
    - name: nodejs
    - require:
      - cmd: remove_nodejs_legacy
