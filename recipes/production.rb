# normal provisioning
include_recipe "chanakya::base"

# disable password ssh
node.default['openssh']['server']['password_authentication'] = 'no'
include_recipe "openssh"

# copy root key to user if no ssh directory
unless File.directory?("/home/#{node['chanakya']['user']}/.ssh")
    execute "mkdir /home/#{node['chanakya']['user']}/.ssh"
    execute "cp /root/.ssh/authorized_keys /home/#{node['chanakya']['user']}/.ssh/"
    execute "chown #{node['chanakya']['user']} /home/#{node['chanakya']['user']}/.ssh/authorized_keys"
end

# firewall
include_recipe "firewall"
rules = [['ssh',22],['http',80],['ssl',443]]
rules.each do |r|
  firewall_rule r[0] do
    port r[1]
    action :allow
  end
end
firewall 'ufw'

include_recipe "chanakya::deploy"
