include:
  - solr

solr_install:
  cmd.script:
    - cwd: /var/www/{{ pillar['project_name']}}-{{ pillar['environment']}}
    - name: salt://solr/solr-install.sh
    - user: {{ pillar['project_name'] }}

solr_project_dir:
  file.directory:
    - name: /var/www/{{ pillar['project_name']}}-{{ pillar['environment']}}/apache-solr-3.6.2/website
    - user: {{ pillar['project_name'] }}
    - group: admin
    - dir_mode: 775
    - recurse:
        - user
        - group
        - mode
    - require:
      - group: admin
      - cmd: solr_install

solr_stop_words:
  file.symlink:
    - target: /var/www/{{ pillar['project_name']}}-{{ pillar['environment']}}/apache-solr-3.6.2/website/solr/conf/lang/stopwords_en.txt
    - name: /var/www/{{ pillar['project_name']}}-{{ pillar['environment']}}/apache-solr-3.6.2/website/solr/conf/stopwords_en.txt
    - user: {{ pillar['project_name'] }}
    - group: admin
    - require:
      - group: admin
      - file: solr_project_dir
