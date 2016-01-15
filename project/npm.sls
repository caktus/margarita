{% import 'project/_vars.sls' as vars with context %}

npm_installs:
  cmd.run:
    - name: npm install; npm update
    - cwd: "{{ vars.source_dir }}"
    - user: {{ pillar['project_name'] }}
    - require:
      - pkg: nodejs
    - require_in:
      - cmd: collectstatic

npm_run_build:
  cmd.run:
    - name: npm run build
    - cwd: "{{ vars.source_dir }}"
    - user: {{ pillar['project_name'] }}
    - require:
      - cmd: npm_installs
    - require_in:
      - cmd: collectstatic
