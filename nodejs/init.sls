node-pkgs:
  pkg:
    - installed
    - names:
      - npm
      - nodejs-legacy

# note: 'nodejs-legacy' is an ubuntu package that installs node then adds
# a symlink to /usr/bin/node, which is where every other Linux distribution
# puts the node executable.
