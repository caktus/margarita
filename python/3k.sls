deadsnakes:
  pkgrepo.managed:
    - humanname: Deadsnakes PPA
    - ppa: fkrull/deadsnakes

python3-pkgs:
  pkg:
    - installed
    - names:
      - python3.3
      - python3.3-dev
    - require:
      - pkgrepo: deadsnakes
