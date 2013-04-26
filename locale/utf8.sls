# salt's locale.system only sets LANG but we want to set LC_ALL as well
#es_ES.UTF-8:
#  locale.system

lang:
    file.sed:
       - name: /etc/default/locale
       - before: ^LANG=.*
       - after: LANG=en_US.UTF-8

lc_all:
    file.sed:
       - name: /etc/default/locale
       - before: ^LC_ALL=.*
       - after: LC_ALL=en_US.UTF-8
