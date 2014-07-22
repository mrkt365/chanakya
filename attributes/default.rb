default['chanakya']['user'] = 'udbhav'
default['chanakya']['app_root'] = "/home/#{node['chanakya']['user']}/app"
default['chanakya']['password_protect'] = false
default['chanakya']['ssl_enabled'] = true
default['chanakya']['use_migrations'] = true
default['chanakya']['gunicorn_settings_path'] = 'gunicorn_settings.py'
default['chanakya']['wsgi_path'] = 'chanakya.wsgi:application'
