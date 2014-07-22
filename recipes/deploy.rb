execute "git pull" do
  command "git pull origin #{node['chanakya']['git_branch']}"
  cwd node['chanakya']['app_root']
  user node['chanakya']['user']
end

# python requirements
execute "python_requirements" do
  command "env/bin/pip install -r requirements.txt"
  cwd node['chanakya']['app_root']
  user node['chanakya']['user']
end

# syncdb and migrations
execute "syncdb" do
  command "env/bin/python src/manage.py syncdb --noinput"
  cwd node['chanakya']['app_root']
  user node['chanakya']['user']
end

execute "migrate" do
  command "env/bin/python src/manage.py migrate"
  cwd node['chanakya']['app_root']
  user node['chanakya']['user']
end

# collectstatic
execute "collectstatic" do
  command "env/bin/python src/manage.py collectstatic --noinput"
  cwd node['chanakya']['app_root']
  user node['chanakya']['user']
  user node['chanakya']['user']
end

# restart gunicorn
execute "supervisorctl restart gunicorn"

# flush memcached
execute "echo 'flush_all' | nc localhost 11211"
