name             'jku-mysql'
maintainer       'Jakub Kułak'
maintainer_email 'jakub.kulak@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures jku-mysql'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'mysql2_chef_gem', '~> 1.0.2'
depends 'database', '~> 4.0.9'
depends 'mysql', '~> 6.1.0'
