deadsnakes:
  pkgrepo.managed:
    - humanname: Deadsnakes PPA
    - ppa: fkrull/deadsnakes

python-base-pkgs:
  pkg:
    - installed
    - names:
      - build-essential

python-headers:
  pkg:
    - installed
    - names:
      - libpq-dev
      - libev-dev
      - libevent-dev
      - libmemcached-dev
      - libjpeg8
      - libjpeg8-dev
      - libfreetype6
      - libfreetype6-dev
      - zlib1g
      - zlib1g-dev
      - libxml2-dev
      - libxslt1-dev
      - ghostscript

pip:
  cmd.run:
    - unless: test -x /usr/local/bin/pip
    - name: |
        cd /tmp
        wget -c https://bootstrap.pypa.io/get-pip.py
        python get-pip.py
    - cwd: /tmp
    - user: root
  pip.installed:
    - upgrade: True

virtualenv:
  pip.installed:
    - upgrade: True
    - require:
      - pip: pip

/usr/lib/libz.so:
  file.symlink:
    - target: /usr/lib/{{ grains['cpuarch'] }}-linux-gnu/libz.so
    - require:
      - pkg: python-headers

/usr/lib/libfreetype.so:
  file.symlink:
    - target: /usr/lib/{{ grains['cpuarch'] }}-linux-gnu/libfreetype.so
    - require:
      - pkg: python-headers

/usr/lib/libjpeg.so:
  file.symlink:
    - target: /usr/lib/{{ grains['cpuarch'] }}-linux-gnu/libjpeg.so
    - require:
      - pkg: python-headers
