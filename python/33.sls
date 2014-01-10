include:
  - python

python-33-pkgs:
  pkg:
    - installed
    - names:
      - python3.3
      - python3.3-dev
    - require:
      - pkgrepo: deadsnakes
