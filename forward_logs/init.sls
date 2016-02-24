# Forward logs to LOG_DESTINATION
include:
  - syslog

send_logs_to_remote_log_server:
  file.managed:
    - name: /etc/rsyslog.d/remote_log_server.conf
    - source: salt://forward_logs/remote_log_server.conf
    - template: jinja
    - context:
        LOG_DESTINATION: {{ pillar['secrets']['LOG_DESTINATION'] }}

restart_syslog_for_remote_log_server:
  cmd.run:
    - name: restart rsyslog
    - onchanges:
        - file: send_logs_to_remote_log_server
