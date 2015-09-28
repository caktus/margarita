# Shell script to run a management command
cd {{ directory }}
{{ virtualenv_root }}/bin/python {{ directory }}/manage.py $@
