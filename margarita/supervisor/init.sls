supervisor:
  pkg:
    - installed
  service:
    - running
    - enable: True

# update command that can easily be triggered using watch_in
supervisor_update:
  cmd.run:
    - name: supervisorctl update
    - user: root
    - require:
      - pkg: supervisor
