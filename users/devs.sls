admin:
    group.present:
        - name: admin
        - system: True

{% if 'users' in pillar %}
{% for user, args in pillar['users'].iteritems() %}
{{ user }}:
    user.present:
        - name: {{ user }}
        - shell: /bin/bash
        - home: /home/{{ user }}
{% if 'groups' in args %}
        - groups: {{ args['groups'] }}
{% endif %}
    require:
      - group: admin

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
