ufw:
  pkg:
    - installed
  service.running:
    - enable: True

firewall_policy:
  ufw.default:
    - policy: deny
    - require:
      - pkg: ufw

firewall_status:
  ufw.enabled:
    - enabled: true
    - require:
      - pkg: ufw