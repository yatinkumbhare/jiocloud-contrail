class contrail::vrouter (
  $vrouter_interface,
  $vrouter_physical_interface,
  $vrouter_ip,
  $discovery_server,
  $vrouter_mac,
  $vrouter_num_controllers = 2,
  $vrouter_gw,
  $vrouter_cidr,
  $metadata_proxy_shared_secret = undef,
  $vrouter_num_controllers,
  $edge_router_address,
) {

  File['/etc/libvirt/qemu.conf'] ~> Service['libvirt']

  package { 'ufw': 
	ensure 	=> absent,
  }

#$contrail_pkgs_to_install = ['contrail-openstack-vrouter','contrail-vrouter','contrail-libs','supervisor-contrail','python-xmltodict','contrail-analytics-venv','contrail-api-lib','contrail-api-venv','contrail-setup']	
$contrail_pkgs_to_install = [ 'contrail-openstack-vrouter','contrail-nova-vif' ,'contrail-nodemgr','contrail-vrouter-init', 'contrail-api-lib', 'contrail-libs' ] 
package {$contrail_pkgs_to_install:
ensure => installed,
	}-> 

  file { '/etc/contrail':
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }  

  file { '/etc/contrail/agent_param':
    ensure => file,
    owner => root,
    group => root,
    mode => 644,
    content => template("contrail/agent_param.erb"),
    notify => Service['contrail-vrouter'],
  }

  if $vrouter_ip {
    file { '/etc/contrail/agent.conf':
      ensure => file,
      owner => root,
      group => root,
      mode => 644,
      content => template("contrail/agent.conf.erb"),
      notify => Service['contrail-vrouter'],
    }
  
    file { '/etc/contrail/default_pmac':
      ensure => file,
      owner => root,
      group => root,
      mode => 644,
      content => $vrouter_mac,
      notify => Service['contrail-vrouter'],
    }
  }

  file { '/etc/contrail/vrouter_nodemgr_param':
    ensure => file,
    owner => root,
    group => root,
    mode => 644,
    content => "DISCOVERY=$discovery_server\n",
    notify => Service['contrail-vrouter'],
  }

  file { '/var/crash': 
    ensure => directory,
    owner => root,
    group => root,
    mode => 755,
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => file,
    owner => root,
    group => root,
    mode => 644,
    source => 'puppet:///modules/contrail/_etc_libvirt_qemu.conf',
  }

  sysctl::value { 'kernel.core_pattern': value => '/var/crash/core.%e.%p.%h.%t' }
  sysctl::value { 'net.ipv4.ip_forward': value => 1 }

  service { 'contrail-vrouter':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
  }


}
