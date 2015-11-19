send_logs_to_papertrail:
  file.managed:
    - name: /etc/rsyslog.d/papertrail.conf
    - source: salt://papertrail/papertrail.conf
    - template: jinja
    - context:
        PAPERTRAIL_ADDRESS: {{ pillar['secrets']['PAPERTRAIL_ADDRESS'] }}

restart_syslog_for_papertrail:
  cmd.run:
    - name: restart rsyslog
    - onchanges:
        - file: send_logs_to_papertrail
