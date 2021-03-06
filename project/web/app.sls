{% import 'project/_vars.sls' as vars with context %}

include:
  - supervisor.pip
  - project.dirs
  - project.venv
  - project.django
  - postfix
  - ufw
  - nodejs
  - project.npm

gunicorn_requirements:
  pip.installed:
    - name: "gunicorn>=19.1,<19.2"
    - bin_env: {{ vars.venv_dir }}
    - upgrade: true
    - require:
      - virtualenv: venv

gunicorn_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ pillar['project_name'] }}-gunicorn.conf
    - source: salt://project/web/gunicorn.conf
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - context:
        log_dir: "{{ vars.log_dir }}"
        settings: "{{ pillar['project_name'] }}.settings.deploy"
        virtualenv_root: "{{ vars.venv_dir }}"
        directory: "{{ vars.source_dir }}"
        use_newrelic: {{ vars.use_newrelic }}
    - require:
      - pip: supervisor
      - file: log_dir
      - pip: pip_requirements
      - pip: gunicorn_requirements
    - watch_in:
      - cmd: supervisor_update

gunicorn_process:
  supervisord.running:
    - name: {{ pillar['project_name'] }}-server
    - restart: True
    - require:
      - file: gunicorn_conf

{% for host, ifaces in vars.balancer_minions.items() %}
app_allow-{{ vars.get_primary_ip(host, ifaces) }}:
  ufw.allow:
    - name: '8000'
    - enabled: true
    - from: {{ vars.get_primary_ip(host, ifaces) }}
    - require:
      - pkg: ufw
{% endfor %}

less:
  cmd.run:
    - name: npm install less@{{ pillar['less_version'] }} -g
    - user: root
    - unless: "which lessc && lessc --version | grep {{ pillar['less_version'] }}"
    - require:
      - pkg: nodejs
  file.symlink:
    - name: /usr/bin/lessc
    - target: /usr/local/bin/lessc
    - user: root
    - require:
      - cmd: less

collectstatic:
  cmd.run:
    - name: "{{ vars.path_from_root('manage.sh') }} collectstatic --noinput"
    - user: {{ pillar['project_name'] }}
    - group: {{ pillar['project_name'] }}
    - require:
      - file: manage
      - cmd: npm_run_build

migrate:
  cmd.run:
    - name: "{{ vars.path_from_root('manage.sh') }} migrate --noinput"
    - user: {{ pillar['project_name'] }}
    - group: {{ pillar['project_name'] }}
    - require:
      - file: manage
    - order: last
