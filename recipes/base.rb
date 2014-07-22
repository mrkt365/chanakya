include_recipe "apt"
include_recipe "locale"
include_recipe "nginx"
include_recipe "python"

ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"
include_recipe "postgresql::server"

include_recipe "nodejs::install_from_package"
include_recipe "supervisor"

# install git
apt_package "git"

# disable strict host key checking for github
template "/home/#{node['chanakya']['user']}/.ssh/config" do
  source "ssh-config.erb"
  owner node['chanakya']['user']
end

# create directory and clone repo if it doesn't exist
unless File.directory?(node['chanakya']['app_root'])
  execute "git clone" do
    command "git clone -b #{node['chanakya']['git_branch']} #{node['chanakya']['git_repo']}"
    cwd "/home/#{node['chanakya']['user']}"
    user node['chanakya']['user']
  end
end

# virtualenv
python_virtualenv "#{node['chanakya']['app_root']}/env" do
  action :create
  owner node['chanakya']['user']
end

# required packages
packages = ['libjpeg-dev', 'libfreetype6', 'libfreetype6-dev',
  'zlib1g-dev', 'libxml2-dev' ,'libxslt-dev']

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# python requirements
execute "python_requirements" do
  command "env/bin/pip install -r requirements.txt"
  cwd node['chanakya']['app_root']
end

apt_package "memcached"

# less
execute "npm install -g less"

# create db role and db if they don't exist
db_user = node['chanakya']['user']
db_name = node['chanakya']['db']['name']

execute "create_db_role" do
  command "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{db_user}'\" | grep -q 1 || createuser -SDR #{db_user}"
  user "postgres"
end

execute "create_db" do
  command "psql -lqt | cut -d \\| -f 1 | grep -wq #{db_name} || createdb -O #{db_user} #{db_name}"
  user "postgres"
end

# nginx conf
template "/etc/nginx/sites-available/chanakya" do
  source "nginx.erb"
  owner node['nginx']['user']
  group node['nginx']['user']
  variables({app_root: node['chanakya']['app_root'],
    hostname: node['chanakya']['hostname'],
    name: node['name'],
    user: node['chanakya']['user'],
    protect: node['chanakya']['password_protect'],
    ssl_enabled: node['chanakya']['ssl_enabled']})
end

# nginx default site
begin
  r = resources(:template => "#{node['nginx']['dir']}/sites-available/default")
  r.cookbook "chanakya"
rescue Chef::Exceptions::ResourceNotFound
  Chef::Log.warn "could not find template to override!"
end

%w[ /var /var/www /var/www/nginx-default ].each do |path|
  directory path do
    owner node['nginx']['user']
    group node['nginx']['user']
  end
end

template "#{node['nginx']['default_root']}/index.html" do
  source "nginx-default.html.erb"
  owner node['nginx']['user']
  group node['nginx']['user']
end

service "nginx" do
  action :restart
end

# gunicorn logrotate
directory "/var/log/gunicorn" do
  owner node['chanakya']['user']
  group "root"
end

template "/etc/logrotate.d/gunicorn" do
  source "gunicorn_logrotate.erb"
  variables({user: node['chanakya']['user']})
end

# supervisor
template "/etc/supervisor.d/chanakya.conf" do
  source "supervisor.erb"
  variables({app_root: node['chanakya']['app_root'],
    user: node['chanakya']['user']})
end

service "supervisor" do
  action :restart
end
