{% import 'project/_vars.sls' as vars with context %}
{% set auth_file=vars.auth_file %}
{% set self_signed='ssl_key' not in pillar or 'ssl_cert' not in pillar %}
{% set dhparams_file = vars.build_path(vars.ssl_dir, 'dhparams.pem') %}
{% set letsencrypt = pillar.get('letsencrypt', False) %}
{% set letsencrypt_domains = pillar.get('letsencrypt_domains', [pillar['domain']]) %}
{% set old_letsencrypt_dir = vars.build_path(vars.root_dir,  'letsencrypt') %}

{% set ssl_certificate = vars.build_path(vars.ssl_dir, pillar['domain'] + ".crt") %}
{% set ssl_certificate_key = vars.build_path(vars.ssl_dir, pillar['domain'] + ".key") %}

include:
  - nginx
  - nginx.cert
  - ufw
  - project.dirs

http_firewall:
  ufw.allow:
    - names:
      - '80'
      - '443'
    - enabled: true

public_dir:
  file.directory:
    - name: {{ vars.public_dir }}
    - user: {{ pillar['project_name'] }}
    - group: www-data
    - mode: 775
    - makedirs: True
    - require:
      - file: root_dir

ssl_dir:
  file.directory:
    - name: {{ vars.ssl_dir }}
    - user: root
    - group: www-data
    - mode: 644
    - makedirs: True
    - require:
      - file: root_dir

{% if self_signed %}
# Note: even if we are using letsencrypt, we'll need a temporary SSL certificate
# so that we can run nginx while getting the real certificate from letsencrypt.
ssl_cert:
  cmd.run:
    - name: cd {{ vars.ssl_dir }} && /var/lib/nginx/generate-cert.sh {{ pillar['domain'] }}
    - cwd: {{ vars.ssl_dir }}
    - user: root
    - unless: test -s {{ ssl_certificate }}
    - require:
      - file: ssl_dir
      - file: generate_cert
    - watch_in:
      - service: nginx
{% else %}
ssl_key:
  file.managed:
    - name: {{ ssl_certificate_key }}
    - contents_pillar: ssl_key
    - user: root
    - mode: 600
    - require:
      - file: ssl_dir
    - watch_in:
      - service: nginx

ssl_cert:
  file.managed:
    - name: {{ ssl_certificate }}
    - contents_pillar: ssl_cert
    - user: root
    - mode: 600
    - require:
      - file: ssl_dir
    - watch_in:
      - service: nginx
{% endif %}


{% if 'http_auth' in pillar %}
apache2-utils:
  pkg:
    - installed

clear_auth_file:
  file.absent:
    - name: {{ auth_file }}
    - require:
      - file: root_dir
      - pkg: apache2-utils

auth_file:
  cmd.run:
    - names:
{%- for key, value in pillar['http_auth'].items() %}
      - htpasswd -bd {{ auth_file }} {{ key }} {{ value }}
{% endfor %}
    - require:
      - pkg: apache2-utils
      - file: root_dir
      - file: clear_auth_file
      - file: {{ auth_file }}

{{ auth_file }}:
  file.managed:
    - user: root
    - group: www-data
    - mode: 640
    - require:
      - file: root_dir
      - file: clear_auth_file
    - watch_in:
      - service: nginx
{% endif %}

dhparams_file:
  cmd.run:
    - name: openssl dhparam -out {{ dhparams_file }} {{ pillar.get('dhparam_numbits', 2048) }}
    - unless: test -f {{ dhparams_file }}

nginx_conf:
  file.managed:
    - name: /etc/nginx/sites-enabled/{{ pillar['project_name'] }}.conf
    - source: salt://project/web/site.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        public_root: "{{ vars.public_dir }}"
        log_dir: "{{ vars.log_dir }}"
        ssl_certificate: {{ ssl_certificate }}
        ssl_certificate_key: {{ ssl_certificate_key }}
        dhparams_file: "{{ dhparams_file }}"
        servers:
{% for host, ifaces in vars.web_minions.items() %}
{% set host_addr = vars.get_primary_ip(host, ifaces) %}
          - {% if host_addr == vars.current_ip %}'127.0.0.1'{% else %}{{ host_addr }}{% endif %}
{% endfor %}
        {%- if 'http_auth' in pillar %}
        auth_file: "{{ auth_file }}"
        {% endif %}
    - require:
      - pkg: nginx
      - file: log_dir
      - file: ssl_dir
      - cmd: dhparams_file
      {%- if self_signed %}
      - cmd: ssl_cert
      {% else %}
      - file: ssl_key
      - file: ssl_cert
      {% endif %}
      {%- if 'http_auth' in pillar %}
      - cmd: auth_file
      {% endif %}
    - watch_in:
      - service: nginx

{% if letsencrypt %}
# Now that we have nginx running, we can get a real certificate.

gnupg2:
  pkg:
    - installed

/tmp/certbot-auto.asc:
  file.managed:
    - name: /tmp/certbot-auto.asc
    - source: https://dl.eff.org/certbot-auto.asc
    - skip_verify: True

install_certbot:
  file.managed:
    - name: /usr/local/bin/certbot-auto
    - source: https://dl.eff.org/certbot-auto
    - skip_verify: True
    - mode: 755

receive_certbot_gpg_key:
  cmd.run:
    - name: gpg2 --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2
    - require:
      - pkg: gnupg2

verify_certbot_download:
  cmd.run:
    - name: gpg2 --trusted-key 4D17C995CD9775F2 --verify /tmp/certbot-auto.asc /usr/local/bin/certbot-auto
    - require:
      - file: /tmp/certbot-auto.asc
      - file: install_certbot
      - cmd: receive_certbot_gpg_key

# Run certbot to get a key and certificate
run_certbot:
  cmd.run:
    - name: certbot-auto certonly --webroot --webroot-path {{ vars.public_dir }} {% for domain in letsencrypt_domains %}--domain {{ domain }} {% endfor %} --email={{ pillar['admin_email'] }} --agree-tos --text --quiet --no-self-upgrade
    - unless: test -s /etc/letsencrypt/live/{{ pillar['domain'] }}/fullchain.pem -a -s /etc/letsencrypt/live/{{ pillar['domain'] }}/privkey.pem
    - require:
      - file: install_certbot
      - cmd: verify_certbot_download
      - file: nginx_conf

link_cert:
  file.symlink:
    - name: {{ ssl_certificate }}
    - target: /etc/letsencrypt/live/{{ pillar['domain'] }}/fullchain.pem
    - force: true
    - require:
      - cmd: run_certbot

link_key:
  file.symlink:
    - name: {{ ssl_certificate_key }}
    - target: /etc/letsencrypt/live/{{ pillar['domain'] }}/privkey.pem
    - force: true
    - require:
      - file: link_cert
    - watch_in:
      - service: nginx

# Twice a day, renew our cert(s) if we need to. This will only renew them if
# they're within 30 days of expiring, so it's not a big burden on the certificate
# service.  (In fact, it's recommended to be this often, in the rare case of a
# LetsEncrypt initiated revocation) https://certbot.eff.org/#ubuntutrusty-nginx
renew_certbot:
  cron.present:
    - name: /usr/bin/env PATH=/usr/local/bin:$PATH /usr/local/bin/certbot-auto renew --quiet --no-self-upgrade --post-hook "/usr/sbin/service nginx reload"
    - identifier: renew_certbot
    - minute: random
    - hour: "3,15"
    - require:
       - file: install_certbot
       - cmd: run_certbot

# Salt state to remove the previous git checkout of letsencrypt
remove_old_letsencrypt:
  cron.absent:
    - identifier: renew_letsencrypt
  file.directory:
    - name: {{ old_letsencrypt_dir }}
    - clean: True

{% endif %}
