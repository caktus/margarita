include:
  - users.groups

{% if 'users' in pillar and pillar['users'] %}
{% for user, args in pillar['users'].iteritems() %}
{{ user }}:
  user.present:
    - name: {{ user }}
    - shell: /bin/bash
    - home: /home/{{ user }}
    - remove_groups: False
{% if 'groups' in args %}
    - groups: {{ args['groups'] }}
{% else %}
    - groups: [admin, login]
    - require:
      - group: admin
      - group: login
{% endif %}

{% if 'public_key' in args %}
  ssh_auth:
    - present
    - user: {{ user }}
    - require:
      - user: {{ user }}
    - names:
{%- for key in args.get('public_key', []) %}
      - {{ key }}
{% endfor %}
{% endif %}

{% endfor %}
{% endif %}

{% if 'users' in pillar and pillar['users'] %}
purge_users:
  cmd.script:
    - cwd: /var/www/{{ pillar['project_name']}}
    - name: salt://users/purge-users.py {% for user in pillar['users'] %}--keep={{ user }} {% endfor %}
    - user: root
    - require:
{% for user in pillar['users'] %}
      - user: {{ user }}
{% endfor %}
{% endif %}
