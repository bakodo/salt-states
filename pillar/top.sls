base:
  '*':
    - settings
  'id:app1.example.com':
    - match: grains
    # make the variables available
    - apps.app1.settings
    - apps.app1.django.settings
    - apps.app1.deploy_keys.id_rsa
    # TODO: will a dot in a file name will be a problem?
    - apps.app1.deploy_keys.id_rsa.pub