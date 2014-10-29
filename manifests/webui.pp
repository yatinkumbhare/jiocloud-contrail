#
# Class: contrail::webui
#   Provide web based ui
#
# == Parameters
#
#
#
class contrail::webui (
  $package_ensure     = 'present',
  $contrail_ip        = $::ipaddress,
  $webui_ip           = $::ipaddress,
  $config_ip          = $::ipaddress,
  $analytics_data_ttl = 48, ## Number of hours to keep the data
  $cassandra_ip_list  = [$::ipaddress],
  $redis_ip           = $::ipaddress,
  $cassandra_port     = 9160,
  $glance_address     = $::ipaddress,
  $nova_address       = $::ipaddress,
  $keystone_address   = $::ipaddress,
  $cinder_address     = $::ipaddress,
  $collector_ip       = $::ipaddress,
) {

  package {['contrail-web-core','contrail-web-controller']:
    ensure => $package_ensure,
  }

  ##
  # Contrail webui need older version of (0.8.x) nodejs.
  # So pinning it on contrail node.
  ##
  apt::pin {'nodejs_for_contrail_webui':
    priority => 1001,
    packages => 'nodejs',
    version  => '0.8*'
  }

  Apt::Pin<||> -> Package<||>

  file { '/etc/contrail/config.global.js':
    ensure  => present,
    content => template("${module_name}/config.global.js.erb"),
    require=> [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
  }

  file { '/etc/init.d/contrail-webui-jobserver':
    ensure => link,
    target => '/lib/init/upstart-job',
    require=> [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
  }

  service {'contrail-webui-jobserver':
    ensure    => running,
    require   => [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
    subscribe => File['/etc/contrail/config.global.js'],
  }

  file { '/etc/init.d/contrail-webui-webserver':
    ensure => link,
    target => '/lib/init/upstart-job',
    require=> [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
  }

  service {'contrail-webui-webserver':
    ensure    => running,
    require   => [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
    subscribe => File['/etc/contrail/config.global.js'],
  }


}
