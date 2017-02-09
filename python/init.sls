{% set python_version = pillar.get('python_version', '2.7') ~ '' %}

python-pkgs:
  pkg.installed:
    - pkgs:
      - python-pip
      - build-essential
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
      - python{{ python_version }}
      - python{{ python_version }}-dev
{% for name in pillar.get('python_headers', []) %}
      - {{ name }}
{% endfor %}

setuptools:
  pip.installed:
    - name: setuptools<8.0
    - upgrade: True
    - require:
      - pkg: python-pkgs
      - pip: pip

pip:
  pip.installed:
{% if grains['saltversion'] < '2016.3.2' %}
    - name: pip==8.1.1
{% else %}
    - name: pip
    - upgrade: True
{% endif %}
    - require:
      - pkg: python-pkgs

virtualenv:
  pip.installed:
    - upgrade: True
    - require:
      - pip: pip

/usr/lib/libz.so:
  file.symlink:
    - target: /usr/lib/{{ grains['cpuarch'] }}-linux-gnu/libz.so
    - require:
      - pkg: python-pkgs

/usr/lib/libfreetype.so:
  file.symlink:
    - target: /usr/lib/{{ grains['cpuarch'] }}-linux-gnu/libfreetype.so
    - require:
      - pkg: python-pkgs

/usr/lib/libjpeg.so:
  file.symlink:
    - target: /usr/lib/{{ grains['cpuarch'] }}-linux-gnu/libjpeg.so
    - require:
      - pkg: python-pkgs
