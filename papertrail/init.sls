send_logs_to_papertrail:
  file.managed:
    - name: /etc/rsyslog.d/papertrail.conf
    - source: salt://papertrail/papertrail.conf
    - template: jinja
    - context:
        PAPERTRAIL_HOST: {{ pillar['secrets']['PAPERTRAIL_HOST'] }}
        PAPERTRAIL_PORT: {{ pillar['secrets']['PAPERTRAIL_PORT'] }}

restart_syslog_for_papertrail:
  cmd.run:
    - name: restart rsyslog
    - onchanges:
        - file: send_logs_to_papertrail
