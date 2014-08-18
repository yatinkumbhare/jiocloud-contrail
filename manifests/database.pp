## Class contrail::database
class contrail::database (
  $package_name = 'contrail-openstack-database',
  $package_ensure = installed,
  $initial_token = undef,
  $database_dir = '/home/cassandra',
  $cassandra_seeds = [$ipaddress],
  $database_listen_ip = $ipaddress,
  $zk_ip_list = $ipaddress,
  $config_server_ip = $ipaddress,
){

  # Ensure template param file is present with right content.
  file { "/etc/contrail/contrail-nodemgr-database.conf" : 
    ensure  => present,
    before => Service["supervisord-contrail-database"],
    content => template("$module_name/contrail-nodemgr-database.conf.erb"),
  }

  # Ensure template param file is present with right content.
  file { "/etc/contrail/database_nodemgr_param" : 
    ensure  => present,
    before => Service["supervisord-contrail-database"],
    content => template("$module_name/database_nodemgr_param.erb"),
  }

  # Ensure all needed packages are present
  package { $package_name :
    ensure => $package_ensure,
  }
  # The above wrapper package should be broken down to the below packages
  # For Debian/Ubuntu - cassandra (>= 1.1.12) , contrail-setup, supervisor
  # For Centos/Fedora - contrail-api-lib, contrail-database, contrail-setup, openstack-quantum-contrail, supervisor
  # database venv installation
  exec { "database-venv" :
    command   => '/bin/bash -c "source ../bin/activate && pip install * && rm -f * "',
    cwd       => '/opt/contrail/database-venv/archive',
    unless    => [ "[ ! -e /opt/contrail/database-venv/archive/[a-zA-Z0-9][a-zA-Z0-9]* ]",
                "[ ! -f /opt/contrail/database-venv/bin/activate ]" ],
    require   => Package['contrail-openstack-database'],
    provider => "shell",
    logoutput => "true"
  }

  # Ensure that config file and env file are present
  if ($operatingsystem == "Ubuntu") {
    $contrail_cassandra_dir = "/etc/cassandra"
  }
  if ($operatingsystem == "Centos" or $operatingsystem == "Fedora") {
    $contrail_cassandra_dir = "/etc/cassandra/conf"
  }

  ## Make sure cassandra database directory exists
  file { "$database_dir" :
    ensure  => directory,
    require => Package['contrail-openstack-database']
  }

  ## Cassandra configuration
  file { "$contrail_cassandra_dir/cassandra.yaml" :
    ensure  => present,
    require => [ Package['contrail-openstack-database'] ],
    content => template("$module_name/cassandra.yaml.erb"),
  }

  ##Cassandra jvm setup
  file { "$contrail_cassandra_dir/cassandra-env.sh" :
    ensure  => present,
    require => [ Package['contrail-openstack-database'] ],
    content => template("$module_name/cassandra-env.sh.erb"),
  }

  # Below is temporary to work-around in Ubuntu as Service resource fails
  # as upstart is not correctly linked to /etc/init.d/service-name
  if ($operatingsystem == "Ubuntu") {
    file { '/etc/init.d/supervisord-contrail-database':
      ensure => link,
      target => '/lib/init/upstart-job',
      before => Service["supervisord-contrail-database"]
    }
  }
  # Ensure the services needed are running.
  service { "supervisord-contrail-database" :
    enable => true,
    require => [ Package["contrail-openstack-database"],
                Exec['database-venv'] ],
    subscribe => [ File["$contrail_cassandra_dir/cassandra.yaml"],
                   File["$contrail_cassandra_dir/cassandra-env.sh"] ],
    ensure => running,
  }

# end of class contrail::database.
}
