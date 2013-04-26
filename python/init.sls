python-pkgs:
  pkg:
    - installed
    - names:
      - python-pip
      - python-dev
      - build-essential
      - python-imaging

virtualenvwrapper:
  pip.installed:
    - require:
      - pkg: python-pkgs

/usr/lib/libz.so:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libz.so

/usr/lib/libfreetype.so:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libfreetype.so

/usr/lib/libjpeg.so:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libjpeg.so
