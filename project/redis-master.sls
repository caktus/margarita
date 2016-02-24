# Install Redis, listening on all interfaces.
# This does not open the firewall for Redis, so do that elsewhere
# if you need access to the Redis server from other systems.
redis-server:
    pkg.installed:
      - name: redis-server
    service.running:
      - name: redis-server
      - enable: True
      - require:
        - pkg: redis-server
    file.replace:
      - name: /etc/redis/redis.conf
      - pattern: "^bind 127.0.0.1"
      - repl: "# bind 127.0.0.1"
      - require:
        - pkg: redis-server
