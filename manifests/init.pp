# == Class: contrail
#
# This class to setup opencontrail.
#
# === Parameters
#
# [*control_ip_list*]
#   An array of contrail control node IP list
#
# [*keystone_address*]
#  Keystone server
#
# [*keystone_admin_token*]
#  Keystone admin token
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
#   Cassandra Port. Default: 9160
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
# [*rabbitmq_ip*]
#  Rabbitmq server IP
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
# [*manage_repo*]
#  Whether to manage opencontrail (apt) repo or not.
#
# [*enable_svcmon*]
#   Whether to enable svcmon or not. This service is only required if you are
#   using service chaining (service vms)
#
# [*interface*]
#   Network interface to use by contrail services
#
# [*collector_ip*]
#   The IP address of contrail collector.
#   Note: Not sure if it is loadblanced IP or local IP or a list of ip addresses
#
# [*analytics_data_ttl*]
#   How long analytics data to keep in hours. Default: 48 (2 days worth of data)
#
# [*router_asn*]
#   ASN that use in the router. Default: 64512
#
# [*nova_metadata_address*]
#   Nova metadata address
#
# [*nova_metadata_port*]
#   Nova Metadata port. Default: 8775
#
# [*router_name*]
#   Edge router name. This is required to add router to contrail config in order
#   to establish bgp neighbourship with edge router. Default: router1
#
# [*router_ip*]
#   Edge router IP address
#
# [*webui_ip*]
#   Contrail webui IP Address
#
# [*seed*]
#   Specifies that the current node is the seed node. Only the seed node
#   creates objects using the API to avoid race conditions.
#
# === Examples
#
#  class {'::contrail':
#   keystone_address           => '10.1.1.1',
#   keystone_admin_token    => 'keystone_admin_token',
#   keystone_admin_password => 'admin_user_password',
#   keystone_auth_password  => 'neutron_user_pasword',
#   manage_repo             => true,
#  }
#
# === Authors
#
# Harish Kumar <hkumar@d4devops.org>
#
#

class contrail (
  $keystone_admin_token,
  $keystone_admin_password,
  $keystone_auth_password,
  $router_ip                  = undef,
  $router_name                = 'router1',
  $keystone_address           = undef,
  $nova_metadata_address      = undef,
  $nova_metadata_port         = 8775,
  $interface                  = 'eth0',
  $keystone_region            = 'RegionOne',
  $manage_repo                = false,
  $control_ip_list            = [],
  $config_package_name        = 'contrail-config-openstack',
  $package_ensure             = 'present',
  $keystone_admin_port        = 35357,
  $keystone_protocol          = 'http',
  $haproxy_enabled            = true,
  $neutron_ip                 = undef,
  $neutron_port               = 9697,
  $neutron_protocol           = 'http',
  $config_ip                  = undef,
  $webui_ip                   = undef,
  $use_certs                  = false,
  $cassandra_ip_list          = [],
  $api_listen                 = '0.0.0.0',
  $api_local_listen_port      = 9100,
  $api_server_port            = 8082,
  $multi_tenancy              = false,
  $memcache_servers           = '127.0.0.1:11211',
  $zk_ip_list                 = [],
  $redis_ip                   =  undef,
  $rabbit_ip                  =  undef,
  $discovery_listen           = '0.0.0.0',
  $discovery_local_listen_port= 9110,
  $discovery_server_port      = 5998,
  $hc_interval                = 5,
  $enable_svcmon              = false,
  $cassandra_port             = 9160,
  $analytics_data_ttl         = 48,
  $collector_ip               = undef,
  $router_asn                 = 64512,
  $seed                       = true,
) {

  ##
  # Validate the parameters
  ##

  validate_array($control_ip_list)
  validate_array($cassandra_ip_list)
  validate_array($zk_ip_list)
  validate_bool($haproxy_enabled)
  validate_bool($use_certs)
  validate_bool($multi_tenancy)
  validate_bool($manage_repo)
  validate_bool($enable_svcmon)
  validate_re($keystone_admin_port, '\d+')
  validate_re($neutron_port, '\d+')
  validate_re($api_local_listen_port, '\d+')
  validate_re($api_server_port, '\d+')
  validate_re($discovery_local_listen_port, '\d+')
  validate_re($discovery_server_port, '\d+')
  validate_re($cassandra_port, '\d+')
  validate_re($analytics_data_ttl, '\d+')
  validate_re($hc_interval, '\d+')
  validate_re($router_asn, '\d+')
  validate_re($nova_metadata_port, '\d+')
  validate_string($keystone_address)
  validate_string($nova_metadata_address)
  validate_string($keystone_region)
  validate_string($keystone_admin_token)
  validate_string($keystone_admin_password)
  validate_string($keystone_auth_password)
  validate_string($redis_ip)
  validate_string($collector_ip)
  validate_string($rabbit_ip)
  validate_string($config_package_name)
  validate_string($package_ensure)
  validate_string($keystone_protocol)
  validate_string($neutron_ip)
  validate_string($neutron_protocol)
  validate_string($config_ip)
  validate_string($webui_ip)
  validate_string($api_listen)
  validate_string($memcache_servers)
  validate_string($router_name)
  validate_string($router_ip)

  ##
  # Declaring anchors
  ##
  anchor {'contrail::start':}
  anchor {'contrail::end_base_services':
    before  => Anchor['contrail::end'],
    require => Anchor['contrail::start'],
  }
  anchor {'contrail::end':}

  ##
  # Fail if the interface provided doesn't have any IP address associated
  ##

  $contrail_ip = inline_template("<%= scope.lookupvar('ipaddress_' + @interface) %>")

  if empty($contrail_ip) {
    fail("Interface provided (${interface}) doesn't have any IP address associated")
  }

  ##
  # Set defaults
  ##

  if ! $nova_metadata_address {
    $nova_metadata_address_orig = $contrail_ip
  } else {
    $nova_metadata_address_orig = $nova_metadata_address
  }

  if ! $keystone_address {
    $keystone_address_orig = $contrail_ip
  } else {
    $keystone_address_orig = $keystone_address
  }

  if empty($control_ip_list) {
    $control_ip_list_orig = [$contrail_ip]
  } else {
    $control_ip_list_orig = $control_ip_list
  }

  if ! $neutron_ip {
    $neutron_ip_orig = $contrail_ip
  } else {
    $neutron_ip_orig = $neutron_ip
  }

  if ! $config_ip {
    $config_ip_orig = $contrail_ip
  } else {
    $config_ip_orig = $config_ip
  }

  if ! $webui_ip {
    $webui_ip_orig = $contrail_ip
  } else {
    $webui_ip_orig = $webui_ip
  }

  if ! $collector_ip {
    $collector_ip_orig = $contrail_ip
  } else {
    $collector_ip_orig = $collector_ip
  }

  if empty($cassandra_ip_list) {
    $cassandra_ip_list_orig = [$contrail_ip]
  } else {
    $cassandra_ip_list_orig = $cassandra_ip_list
  }

  if empty($zk_ip_list) {
    $zk_ip_list_orig = [$contrail_ip]
  } else {
    $zk_ip_list_orig = $zk_ip_list
  }

  if ! $redis_ip {
    $redis_ip_orig = $contrail_ip
  } else {
    $redis_ip_orig = $redis_ip
  }

  if ! $rabbit_ip {
    $rabbit_ip_orig = $contrail_ip
  } else {
    $rabbit_ip_orig = $rabbit_ip
  }


  ##
  #  Setup repo if enabled.
  ##
  if $manage_repo {
    include contrail::repo

    ##
    # All package operations should follow apt::source
    ##

    Apt::Source<||> -> Package<||>
  }


  ##
  # contrail::system_config does operating system parameter changes,
  #       and make the system ready to run contrail services
  ##

  class {'contrail::system_config':
    contrail_ip => $contrail_ip,
  }

  Anchor['contrail::start'] ->
  Class['contrail::system_config'] ->
  Anchor['contrail::end_base_services']

  ##
  # Manage contrail ifmap
  ##
  class {'contrail::ifmap':
    control_ip_list => $control_ip_list_orig
  }

  Anchor['contrail::start'] ->
  Class['contrail::system_config'] ->
  Anchor['contrail::end_base_services']

  ##
  # Manage contrail config services
  ##
  class {'contrail::config':
    keystone_host              => $keystone_address_orig,
    nova_metadata_address      => $nova_metadata_address_orig,
    nova_metadata_port         => $nova_metadata_port,
    keystone_admin_token       => $keystone_admin_token,
    keystone_admin_password    => $keystone_admin_password,
    keystone_auth_password     => $keystone_auth_password,
    keystone_region            => $keystone_region,
    package_name               => $config_package_name,
    package_ensure             => $package_ensure,
    keystone_admin_port        => $keystone_admin_port,
    keystone_protocol          => $keystone_protocol,
    haproxy_enabled            => $haproxy_enabled,
    neutron_ip                 => $neutron_ip_orig,
    neutron_port               => $neutron_port,
    neutron_protocol           => $neutron_protocol,
    config_ip                  => $config_ip_orig,
    use_certs                  => $use_certs,
    cassandra_ip_list          => $cassandra_ip_list_orig,
    api_listen                 => $api_listen,
    api_local_listen_port      => $api_local_listen_port,
    api_server_port            => $api_server_port,
    multi_tenancy              => $multi_tenancy,
    memcache_servers           => $memcache_servers,
    zk_ip_list                 => $zk_ip_list_orig,
    redis_ip                   => $redis_ip_orig,
    rabbit_ip                  => $rabbit_ip_orig,
    discovery_listen           => $discovery_listen,
    discovery_local_listen_port=> $discovery_local_listen_port,
    discovery_server_port      => $discovery_server_port,
    hc_interval                => $hc_interval,
    enable_svcmon              => $enable_svcmon,
    router_asn                 => $router_asn,
    router_name                => $router_name,
    router_ip                  => $router_ip,
    contrail_ip                => $contrail_ip,
    seed                       => $seed,
  }

  Anchor['contrail::end_base_services'] ->
  Class['contrail::config'] ->
  Anchor['contrail::end']

  ##
  # Contrail control services
  ##
  class {'contrail::control':
    control_ip_list => $control_ip_list_orig,
    config_ip       => $config_ip_orig,
    contrail_ip     => $contrail_ip,
  }

  Anchor['contrail::end_base_services'] ->
  Class['contrail::control'] ->
  Anchor['contrail::end']


  ##
  # Contrail analytics collector
  ##
  class {'contrail::collector':
    contrail_ip         => $contrail_ip,
    collector_ip        => $collector_ip_orig,
    config_ip           => $config_ip_orig,
    analytics_data_ttl  => $analytics_data_ttl,
    cassandra_ip_list   => $cassandra_ip_list_orig,
    redis_ip            => $redis_ip_orig,
    cassandra_port      => $cassandra_port,
  }

  Anchor['contrail::end_base_services'] ->
  Class['contrail::collector'] ->
  Anchor['contrail::end']

  ##
  # Contrail webui setup
  ##
  class {'contrail::webui':
    package_ensure      => $package_ensure,
    contrail_ip         => $contrail_ip,
    webui_ip            => $webui_ip_orig,
    config_ip           => $config_ip_orig,
    analytics_data_ttl  => $analytics_data_ttl,
    cassandra_ip_list   => $cassandra_ip_list_orig,
    redis_ip            => $redis_ip_orig,
    glance_address      => $keystone_address_orig,
    nova_address        => $keystone_address_orig,
    keystone_address    => $keystone_address_orig,
    cinder_address      => $keystone_address_orig,
    collector_ip        => $collector_ip_orig,
  }

  Anchor['contrail::end_base_services'] ->
  Class['contrail::webui'] ->
  Anchor['contrail::end']
}
