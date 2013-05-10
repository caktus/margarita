ufw:
  pkg:
    - installed

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