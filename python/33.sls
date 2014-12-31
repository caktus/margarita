include:
  - python

exclude:
  - python.27

python-pkgs:
  pkg:
    - installed
    - pkgs:
      - python3.3
      - python3.3-dev
    - require:
      - pkgrepo: deadsnakes
