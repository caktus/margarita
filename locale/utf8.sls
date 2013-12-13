# salt's locale.system only sets LANG but we want to set LC_ALL as well

/etc/default/locale:
  file.managed:
    - source: salt://locale/locale
    - user: root
    - mode: 644
