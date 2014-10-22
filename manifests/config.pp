#
# Class: contrail::config
#    Manage contrail config services
#
# == Parameters
#
# [*keystone_host*]
#  Keystone server
#
# [*keystone_admin_user*]
#   Keystone admin user. Default: admin
#
# [*keystone_admin_tenant*]
#   Keystone admin tenant. Default: openstack
#
# [*keystone_admin_token*]
#  Keystone admin token.
#  Note: Contrail uses admin_token in some places and admin password in others,
#  so we need both of them.
#
# [*keystone_admin_password*]
#  Keystone admin password
#
# [*keystone_auth_password*]
#  Keystone service user password
#
# [*keystone_admin_port*]
#  Keystone admin port
#
# [*keystone_protocol*]
#  Keystone protocol
#
# [*keystone_region*]
#  Keystone region
#
# [*haproxy_enabled*]
#  Whether to enable local haproxy or not.
# Note: in case local haproxy enabled, all contrail servers will have one
# instance of haproxy running, which will be load balancing the requests to all
# other contrail nodes.
#  There is a problem with this method, in case haproxy is down on one node, any
#  clients connect to this node will cause issues. This must be handled using
#  pacemaker or any other cluster management tools to effectively mange it.
#  Other option is to move the load balancing to external load balancer cluster
#
# [*neutron_ip*]
#  Neutron ip address
# Note: original contrail code make neutron IP as localhost if haproxy is
# enabled. They are configuring haproxy on all nodes, so that any node can load
# balance. Currently I am following the same logic, later this will get changed
# because of the reliability problem mentioned above.
#
# [*neutron_port*]
#  Neutron port
#
# [*neutron_protocol*]
#  Neutron protocol
#
# [*config_ip*]
#  Contrail config server IP which will be used to configure contrail api server
#  Note: This setting is used to determine ifmap server IP and discovery server
#  IP. Original contrail configuration uses local server IP for this
#  configuration. But the issue with that configuration is
#  that if any corresponding required service is down on the the node any other
#  dependant services also will be down. Need to check if this can be a load
#  balanced service.
#
# [*use_certs*]
#  Use certificate authentication for ifmap
#  Note: need confirmation on this definition
#
# [*cassandra_ip_list*]
#  An array of Cassandra server ip list
#
# [*cassandra_port*]
#  Cassandra port, Default: 9160
#
# [*api_listen*]
#  IP Address to listen contrail api
#
# [*api_local_listen_port*]
#  Port to listen contrail API server locally
#  Default: 9100
#
# [*api_server_port*]
#  Load balanced port of contrail api server on which all services connect.
#  Default: 8082
#
# [*multi_tenancy*]
#
#
# [*memcache_servers*]
#  Optional memcache server url in <ip>:<port> form
#
# [*zk_ip_list*]
#  An array of Zookeeper IPs
#
# [*zk_port*]
#  Zookeeper port
#
# [*redis_ip*]
#  Redis server IP
#
# [*rabbit_port*]
#  Rabbitmq port, Default: 5672
#
# [*discovery_listen*]
#  The address on which discovery server to be listen.
#
# [*discovery_local_listen_port*]
#  Discovery server port to be listen locally
#  Default: 9110
#
# [*discovery_server_port*]
#  Load balanced port of contrail discovery server on which the clients connect
#  Default: 5998
#
# [*hc_interval*]
#  Healthcheck interval discovery server use to decide whether to disable that
#  server or not.
#  Default: 5
#
# [*compute_ip*]
#   Need more information
#
# [*enable_svcmon*]
#   Whether to enable svc-mon or not. svcmon is used for service chaining.
#
#

class contrail::config (
  $keystone_host,
  $keystone_admin_token,
  $keystone_admin_password,
  $keystone_auth_password,
  $keystone_admin_user        = 'admin',
  $keystone_admin_tenant      = 'openstack',
  $keystone_region            = 'RegionOne',
  $package_name               = 'contrail-config-openstack',
  $package_ensure             = 'present',
  $keystone_admin_port        = 35357,
  $keystone_protocol          = 'http',
  $haproxy_enabled            = true,
  $neutron_ip                 = $::ipaddress,
  $neutron_port               = 9697,
  $neutron_protocol           = 'http',
  $config_ip                  = $::ipaddress,
  $use_certs                  = false,
  $cassandra_ip_list          = [ $::ipaddress ],
  $cassandra_port             = 9160,
  $api_listen                 = '0.0.0.0',
  $api_local_listen_port      = 9100,
  $api_server_port            = 8082,
  $multi_tenancy              = false,
  $memcache_servers           = '127.0.0.1:11211',
  $zk_ip_list                 = [$::ipaddress],
  $zk_port                    = 2181,
  $redis_ip                   = $::ipaddress,
  $rabbit_ip                  = $::ipaddress,
  $rabbit_port                = 5672,
  $discovery_listen           = '0.0.0.0',
  $discovery_local_listen_port= 9110,
  $discovery_server_port      = 5998,
  $hc_interval                = 5,
  $compute_ip                 = 'None',
  $enable_svcmon              = false,
){

  ##
  ## If ifmap uses certificate authentication, connect to secure port
  ##

  if $use_certs {
    $ifmap_server_port = '8444'
  } else {
    $ifmap_server_port = '8443'
  }

  if $multi_tenancy {
    $contrail_memcache_servers = $memcache_servers
  }

  $package_list = [$package_name, 'contrail-utils']

  package { $package_list:
    ensure => $package_ensure,
  }

  ##
  ## Ensure ctrl-details file is present with right content.
  ##
  file { '/etc/contrail/ctrl-details' :
    ensure  => present,
    content => template("${module_name}/ctrl-details.erb"),
    require   => Package[$package_name]
  }

  ##
  ## Ensure service.token file is present with right content.
  ##

  file { '/etc/contrail/service.token' :
    ensure  => present,
    content => template("${module_name}/service.token.erb"),
    require   => Package[$package_name]
  }

  ##
  ## api_server.conf
  ##

  file { '/etc/contrail/contrail-api.conf' :
    ensure  => present,
    content => template("${module_name}/contrail-api.conf.erb"),
    require   => Package[$package_name]
  }

  file {'/etc/contrail/vnc_api_lib.ini':
    ensure  => present,
    content => template("${module_name}/vnc_api_lib.ini.erb"),
    require   => Package[$package_name]
  }

  file {'/etc/contrail/contrail_plugin.ini':
    ensure  => present,
    content => template("${module_name}/contrail_plugin.ini.erb"),
    require   => Package[$package_name]
  }



  service {'contrail-api':
    ensure    => 'running',
    enable    => true,
    subscribe => [ File['/etc/contrail/contrail-api.conf'],
                  File['/etc/contrail/vnc_api_lib.ini'] ],
  }

  file {'/etc/contrail/contrail-schema.conf':
    ensure  => present,
    content => template("${module_name}/contrail-schema.conf.erb"),
    require   => Package[$package_name]
  }

  service {'contrail-schema':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-schema.conf'],
  }

  ##
  # svcmon is only required for service chaining (service VMs). So only
  # configure it if $enable_svcmon is set.
  ##
  if $enable_svcmon {
    file {'/etc/contrail/svc-monitor.conf':
      ensure  => present,
      content => template("${module_name}/svc-monitor.conf.erb"),
      require   => Package[$package_name]
    }

    service {'contrail-svc-monitor':
      ensure    => 'running',
      enable    => true,
      subscribe => File['/etc/contrail/svc-monitor.conf'],
      require   => Package[$package_name]
    }
  }

  file {'/etc/contrail/contrail-discovery.conf':
    ensure  => present,
    content => template("${module_name}/discovery.conf.erb"),
    require   => Package[$package_name]
  }

  service {'contrail-discovery':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-discovery.conf'],
  }

}
