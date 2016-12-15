{% set root_dir = "/var/www/" + pillar['project_name'] + "/" %}

{% macro get_primary_iface_name(host) -%}
  {# return the name of the primary iface of the specified host. This is either the value hardcoded in the pillar, or the iface associated with the default route. #}
  {{- pillar.get('primary_iface', salt['mine.get'](host, 'network.default_route')[host][0]['interface']) -}}
{% endmacro %}

{% macro get_iface_ip(ifaces, iface_name) -%}
  {# given a list of ifaces and an iface_name, return the IP address associated with that iface #}
  {{- ifaces[iface_name].get('inet', [{}])[0].get('address') -}}
{% endmacro %}

{% macro get_primary_ip(host, ifaces) -%}
  {# Given a minion hostname and a list of its network interfaces, return its primary IP #}
  {{- get_iface_ip(ifaces, get_primary_iface_name(host)) -}}
{%- endmacro %}

{% macro build_path(root, name) -%}
  {{ root }}{%- if not root.endswith('/') -%}/{%- endif -%}{{ name }}
{%- endmacro %}

{% macro path_from_root(name) -%}
  {{ build_path(root_dir, name) }}
{%- endmacro %}

{% set auth_file = path_from_root(".htpasswd") %}
{% set iface = salt['pillar.get']('primary_iface', salt['network.default_route']('inet')[0]['interface']) %}
{% set current_ip = grains['ip_interfaces'].get(iface)[0] %}
{% set log_dir = path_from_root('log') %}
{% set public_dir = path_from_root('public') %}
{% set services_dir = path_from_root('services') %}
{% set ssh_dir = "/home/" + pillar['project_name'] + "/.ssh/" %}
{% set ssl_dir = path_from_root('ssl') %}
{% set source_dir = path_from_root('source') %}
{% set venv_dir = path_from_root('env') %}

{% set web_minions = salt['mine.get']('G@roles:web and G@environment:' + pillar['environment'], 'network.interfaces', expr_form='compound') %}
{% set worker_minions = salt['mine.get']('G@roles:worker and G@environment:' + pillar['environment'], 'network.interfaces', expr_form='compound') %}
{% set app_minions = salt['mine.get']('P@roles:(worker|web) and G@environment:' + pillar['environment'], 'network.interfaces', expr_form='compound') %}
{% set balancer_minions = salt['mine.get']('G@roles:balancer and G@environment:' + pillar['environment'], 'network.interfaces', expr_form='compound') %}

{% set use_newrelic = salt['pillar.get']('secrets:NEW_RELIC_LICENSE_KEY', False) %}
