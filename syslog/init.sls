# We need rsyslog 8.5+ to monitor plaintext log files using wildcards
rsyslog:
  pkgrepo.managed:
    - ppa: adiscon/v8-stable
  pkg.latest:
    - name: rsyslog

# Load the imfile module so we can monitor plaintext log files
load_imfile:
  file.prepend:
    - name: /etc/rsyslog.conf
    - text: |
        module(load="imfile" PollingInterval="10")

restart_rsyslog_if_imfile_added:
  cmd.run:
    - name: restart rsyslog
    - onchanges:
       - file: load_imfile
