#
# Class: contrail::collector
#   Manage contrail analytics collector
#
# == Parameters
#
#
#
class contrail::collector (
  $package_ensure     = 'present',
  $contrail_ip        = $::ipaddress,
  $collector_ip       = $::ipaddress,
  $config_ip          = $::ipaddress,
  $analytics_data_ttl = 48, ## Number of hours to keep the data
  $cassandra_ip_list  = [$::ipaddress],
  $redis_ip           = $::ipaddress,
  $cassandra_port     = 9160,
) {

  package {'contrail-analytics':
    ensure => $package_ensure,
  }

  ##
  ## Ensure contrail-analytics-api.conf file is present with right content.
  ##

  file { '/etc/contrail/contrail-analytics-api.conf':
    ensure  => present,
    content => template("${module_name}/contrail-analytics-api.conf.erb"),
    require => Package['contrail-analytics'],
  }

  ##
  # upstart links under init.d are not installed by the packages, so adding
  # them.
  ##

  file {'/etc/init.d/contrail-analytics-api':
    ensure  => link,
    source  => '/lib/init/upstart-job',
    require => Package['contrail-analytics'],
  }

  service {'contrail-analytics-api':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-analytics-api.conf'],
  }

  file { '/etc/contrail/contrail-collector.conf':
    ensure  => present,
    content => template("${module_name}/contrail-collector.conf.erb"),
    require => Package['contrail-analytics'],
  }

  file {'/etc/init.d/contrail-collector':
    ensure  => link,
    source  => '/lib/init/upstart-job',
    require => Package['contrail-analytics'],
  }

  service {'contrail-collector':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-collector.conf'],
  }

  file { '/etc/contrail/contrail-query-engine.conf':
    ensure  => present,
    content => template("${module_name}/contrail-query-engine.conf.erb"),
    require => Package['contrail-analytics'],
  }

  file {'/etc/init.d/contrail-query-engine':
    ensure  => link,
    source  => '/lib/init/upstart-job',
    require => Package['contrail-analytics'],
  }

  service {'contrail-query-engine':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-query-engine.conf'],
  }
}
