#
# Cookbook Name:: jku-mysql
# Recipe:: default
#
# Copyright 2015, Jakub Kułak
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install required mysql2 gem to use mysql2
mysql2_chef_gem 'default' do
    gem_version '0.3.17'
    action :install
end

# Create a mysql_services
node['jku-mysql']['mysql'].each do |server_data|

    name = server_data[0]
    server = server_data[1]

    mysql_service name do
        port server['port']
        version server['version']
        initial_root_password server['root_password']
        action [:create, :start]
    end

    # Define server connection information
    mysql_connection_info = {
        :host => server['host'],
        :username => 'root',
        :password => server['root_password']
    }

    # Grant privilages
    mysql_database_user 'root' do
        connection mysql_connection_info
        password server['root_password']
        host '%'
        action :grant
    end

    # Create a mysql database
    mysql_database server['db_name'] do
        connection mysql_connection_info
        action :create
    end

    # Create user and grant privilages
    mysql_database_user server['user'] do
      connection    mysql_connection_info
      password      server['user_password']
      database_name server['db_name']
      host          '%'
      privileges    [:select, :insert, :update, :delete, :create, :drop, :index, :alter]
      action        :grant
    end

    # Copy dump file
    cookbook_file "/tmp/db1_2015-09-22.sql" do
      mode 00755
      ignore_failure true
    end

    # Copy dump file
    cookbook_file "/tmp/db1_2015-09-22.sql.example" do
      mode 00755
      ignore_failure true
    end

    # Import an sql dump
    execute 'import' do
      command "mysql -h 127.0.0.1 -u root -p#{server['root_password']} #{server['db_name']} < /tmp/#{server['db_dump']}"
      action :run
      only_if { File.exist?("/tmp/#{server['db_dump']}") }
    end

end
