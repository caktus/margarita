python-pkgs:
  pkg:
    - installed
    - names:
      - python-pip
      - python-dev
      - build-essential
      - python-imaging

python-headers:
  pkg:
    - installed
    - names:
      - libpq-dev
      - libev
      - libev-dev
      - libevent
      - libevent-dev
      - libmemcached-dev
      - libjpeg62
      - libjpeg62-dev
      - libjpeg8
      - libjpeg8-dev
      - libfreetype6
      - libfreetype6-dev
      - zlib1g
      - zlib1g-dev
      - libxml2-dev
      - libxslt1-dev

virtualenv:
  pip.installed:
    - require:
      - pkg: python-pkgs

virtualenvwrapper:
  pip.installed:
    - require:
      - pkg: python-pkgs

/usr/lib/libz.so:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libz.so
    - require:
      - pkg: python-headers

/usr/lib/libfreetype.so:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libfreetype.so
    - require:
      - pkg: python-headers

/usr/lib/libjpeg.so:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libjpeg.so
    - require:
      - pkg: python-headers
