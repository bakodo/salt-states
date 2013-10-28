include:
  - circus
  - deploy

app-pkgs:
  pkg.installed:
    - names:
      - git
      - python-virtualenv
      - python-dev
      - libmysqlclient-dev

webapp:
  git.latest:
    - name: {{ pillar['git_repo'] }}
    - rev: {{ pillar['git_rev'] }}
    - target: /var/www/{{ salt['pillar.get']('repo_name', 'webapp') }}/
    - force: true
    - require:
      - pkg: app-pkgs
      - file: deploykey
      - file: publickey
      - file: ssh_config

settings:
  file.managed:
    - name: /var/www/{{ salt['pillar.get']('repo_name', 'webapp') }}/project/settings.py
    - source: salt://webserver/settings.py
    - template: jinja
    - watch:
      - git: webapp

/var/www/env/{{ salt['pillar.get']('repo_name', 'webapp') }}:
  virtualenv.manage:
    - requirements: /var/www/{{ salt['pillar.get']('repo_name', 'webapp') }}/requirements.txt
    - no_site_packages: true
    - clear: false
    - require:
      - pkg: app-pkgs
      - file: settings

nginx:
  pkg:
    - latest
  service:
    - running
    - watch:
      - file: nginxconf

nginxconf:
  file.managed:
    - name: /etc/nginx/sites-enabled/{{ salt['pillar.get']('repo_name', 'webapp') }}
    - source: salt://webserver/nginx.conf
    - template: jinja
    - makedirs: True
    - mode: 755

gunicorn_circus:
    file.managed:
        - name: /etc/circus.d/gunicorn.ini
        - source: salt://webserver/gunicorn.ini
        - makedirs: True
        - watch_in:
            - service: circusd
