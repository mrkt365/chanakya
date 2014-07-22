name             'chanakya'
maintainer       'Udbhav Gupta'
maintainer_email 'dev@udbhavgupta.com'
description      'Installs/Configures a Django app server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

depends "apt"
depends "locale"
depends "nginx"
depends "python"
depends "postgresql"
depends "nodejs"
depends "ruby_build"
depends "rbenv"
depends "supervisor"
depends "openssh"
depends "firewall"
