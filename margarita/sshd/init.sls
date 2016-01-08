include:
  - ufw
  - fail2ban

openssh-client:
  pkg:
    - installed

ssh:
  pkg.installed:
    - name: openssh-server
  service.running:
    - enable: True
    - watch:
      - file: /etc/ssh/sshd_config
      - pkg: ssh
  require:
    - group: login

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://sshd/sshd_config
    - user: root
    - mode: 644

allow_ssh:
  ufw.allow:
    - name: '22'
    - enabled: true
    - require:
      - pkg: ufw