include:
  - users.groups

# vagrant needs to be in the login group so it can ssh in with
# our ssh config, and in the admin group so it can passwordless
# sudo, which Vagrant needs it to do.

vagrant:
  user.present:
    - name: vagrant
    - remove_groups: False
    - groups: [admin, login]
    - require:
      - group: admin
      - group: login
