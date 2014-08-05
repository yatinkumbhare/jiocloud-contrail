class contrail::zookeeper (
  $zk_ip_list = $ipaddress,
  $zk_index = 1,
) {
  package { 'zookeeper' : ensure => present,}
#    package { 'zookeeperd' : ensure => present,} -> this is not working

  # set high session timeout to survive glance led disk activity
  file { "/etc/contrail/contrail_setup_utils/config-zk-files-setup.sh":
    ensure  => present,
    mode => 0755,
    owner => root,
    group => root,
    require => Package['zookeeper'],
    source => "puppet:///modules/$module_name/config-zk-files-setup.sh"
  }

  $contrail_zk_ip_list_for_shell = inline_template('<%= @zk_ip_list.map{ |ip| "#{ip}" }.join(" ") %>')

  exec { "setup-config-zk-files-setup" :
    command => "/bin/bash /etc/contrail/contrail_setup_utils/config-zk-files-setup.sh $operatingsystem $zk_index $contrail_zk_ip_list_for_shell && echo setup-config-zk-files-setup >> /etc/contrail/contrail_config_exec.out",
    require => File["/etc/contrail/contrail_setup_utils/config-zk-files-setup.sh"],
    unless  => "grep -qx setup-config-zk-files-setup /etc/contrail/contrail_config_exec.out",
    provider => shell,
    logoutput => "true"
  }

  service {'zookeeper':
    ensure => running,
    enable => true,
  }
}
