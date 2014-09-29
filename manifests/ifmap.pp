##
## Class: contrail::ifmap
##
## Configure ifmap server
##
class contrail::ifmap (
  $package_ensure  = 'present',
  $control_ip_list = [$::ipaddress]
) {

  ##
  ## Create /etc/contrail - due to a bug in ifmap-server packaging,
  ##   this directory is required before ifmap-server package installed
  ##

  file {'/etc/contrail':
    ensure => directory,
    before => Package['ifmap-server'],
  }

  package {'ifmap-server':
    ensure => $package_ensure,
  }

  ##
  ## Make sure the MAPC with basic auth user "reader" has readonly access
  ##

  file_line {'add_basic_auth_user_reader_with_readonly':
    ensure  => present,
    line    => 'reader=ro',
    match   => '^[\s\t]*reader=',
    path    => '/etc/ifmap-server/authorization.properties',
    require => Package['ifmap-server'],
    notify  => Service['ifmap-server'],
  }

  ##
  ## Adding extra MAPCs for all contrail nodes along with other required MAPCs
  ## Variables:
  ##  $control_ip_list
  ##

  file { '/etc/ifmap-server/basicauthusers.properties' :
    ensure  => present,
    content => template("${module_name}/basicauthusers.properties.erb"),
    require => Package['ifmap-server'],
    notify  => Service['ifmap-server'],
  }

  file { '/etc/ifmap-server/publisher.properties' :
    ensure  => present,
    require => Package['ifmap-server'],
    source  => "puppet:///modules/${module_name}/publisher.properties",
    notify  => Service['ifmap-server'],
  }

  service {'ifmap-server':
    ensure  => running,
    enable  => true,
    require => Package['ifmap-server'],
  }
}
