# Install Redis, listening only on localhost.
# (Default is to listen on all interfaces.)
redis-server:
    pkg.installed:
      - name: redis-server
    service.running:
      - name: redis-server
      - enable: True
      - require:
        - pkg: redis-server
    file.append:
      - name: /etc/redis/redis.conf
      - text: "bind 127.0.0.1"
      - require:
        - pkg: redis-server
