include:
 - base

deadsnakes:
  pkgrepo.managed:
    - humanname: Deadsnakes PPA
    - ppa: fkrull/deadsnakes
    - require:
      - pkg: base-packages

python-base-pkgs:
  pkg:
    - installed
    - names:
      - python-pip
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

setuptools:
  pip.installed:
    - name: setuptools<8.0
    - upgrade: True
    - require:
      - pkg: python-base-pkgs

pip:
  pip.installed:
    - upgrade: True
    - require:
      - pip: setuptools

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
