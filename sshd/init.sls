login:
    group.present:
        - name: login
        - system: True

openssh-client:
  pkg:
    - installed

ssh:
  pkg.installed:
    - name: openssh-server
  service.running:
    - enable: True
    - watch:
      - file: ssh
      - pkg: ssh
  require:
    - group: login 

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://sshd/sshd_config
    - user: root
    - mode: 644
