#
# Class: contrail::vrouter
#
# == To setup contrail vrouter.
#
#

class contrail::vrouter (
  $discovery_ip,
  $keystone_admin_password,
  $api_ip                     = undef,
  $api_port                   = 8082,
  $package_names              = [ 'contrail-vrouter-agent','contrail-utils',
                                  'contrail-nova-driver','contrail-vrouter-dkms'],
  $package_ensure             = 'installed',
  $vrouter_interface          = 'vhost0',
  $vrouter_physical_interface = 'eth2',
  $vrouter_num_controllers    = 2,
  $vrouter_gw                 = undef,
  $metadata_proxy_secret      = 'set',
  $router_address             = undef,
  $network_mtu                = 1500,
  $hypervisor_type            = 'kvm',
  $autoreboot                = false,
) {

  include contrail::repo


  if has_interface_with($vrouter_interface) {
    $iface_for_vrouter_config = $vrouter_interface
  } elsif has_interface_with($vrouter_physical_interface) {
    $iface_for_vrouter_config = $vrouter_physical_interface
  } else {
    fail("vrouter_physical_interface (${vrouter_physical_interface}) and vrouter_interface (${vrouter_interface}) dont exist")
  }

  if ! $api_ip {
    $api_ip_orig  = $discovery_ip
  } else {
    $api_ip_orig  = $api_ip
  }

  $vrouter_ip  = inline_template("<%= scope.lookupvar('ipaddress_' + @iface_for_vrouter_config) %>")
  $vrouter_mac = inline_template("<%= scope.lookupvar('macaddress_' + @iface_for_vrouter_config) %>")
  $vrouter_netmask = inline_template("<%= scope.lookupvar('netmask_' + @iface_for_vrouter_config) %>")
  $vrouter_cidr = netmask2cidr($vrouter_netmask)

  ##
  # Usually first IP of a network used to be the gateway ip address.
  # So making the first IP as default
  ##
  if $vrouter_gw {
    $vrouter_gw_orig = $vrouter_gw
  } else {
    $vrouter_gw_orig = nextip(inline_template("<%= scope.lookupvar('network_' + @iface_for_vrouter_config) %>"))
  }

  package { 'ufw':
    ensure  => absent,
  }

  package {$package_names:
    ensure => $package_ensure,
  }

  ##
  # Setting up network interfaces
  ##
  network_config {$vrouter_physical_interface:
    ensure  => present,
    family  => 'inet',
    method  => 'manual',
    options => {
                'pre-down' => 'ifconfig $IFACE down',
                'pre-up'   => "ifconfig \$IFACE mtu ${network_mtu} up"
                },
    onboot  => true,
  }

  network_config {$vrouter_interface:
    ensure    => present,
    family    => 'inet',
    method    => 'static',
    ipaddress => $vrouter_ip,
    netmask   => $vrouter_netmask,
    onboot    => true,
    options => { 'pre-up'  => '/usr/local/bin/if-vhost0' }
  }

  ##
  # A reboot is required here after vrouter dkms  package installed/upgraded),
  # because of the kernal module install/upgrade.
  # The package is not installing /var/run/reboot-required, so adding that file
  # if autoreboot is not enabled, so that the reboot can be handled externally.
  # Currently this is only handled in Debian systems.
  # NOTE:
  #   It may need more discussion to how to handle the reboot and it may need to
  #   add more logic to put more control and to add additional operations to be
  #   performed like coordinating the node reboot between multiple compute nodes
  #   so that only a subset of nodes will be rebooted, and/or additional
  #   operations to be performed like vm migrations or any other stuffs.
  #   There are two options to reboot the node,
  #   1. Reboot on refresh signal from Package['contrail-vrouter-dkms'].
  #       The problem here is that in any case the puppet/reboot process get
  #       inturrupted, the system will not be in consistant state
  #   2. Reboot if /var/run/reboot-required file exist
  #       The problem in this method is that it may be other package
  #       installation can install /var/run/reboot-required which will cause
  #       system reboot, not only contrail-vrouter-dkms. This is also an
  #       advantage that the system will always be in good state - no pending
  #       reboot will be there.
  #   Currently choosing #2.
  # TODO:
  #   The package contrail-vrouter-dkms should run notify-reboot-required in
  #   postinstall to notify the requirement for reboot.
  #   Adding a workaround here for now.
  ##
  if $::osfamily == 'Debian' {
    exec {'write_rebootrequired':
      command     => 'export DPKG_MAINTSCRIPT_PACKAGE=contrail-vrouter-dkms; /usr/share/update-notifier/notify-reboot-required',
      refreshonly => true,
      require     => [ Network_config[$vrouter_physical_interface],
                        Network_config[$vrouter_interface] ],
      subscribe   =>  Package['contrail-vrouter-dkms']
    }
    if $autoreboot {
      notify {'Automatic System reboot is enabled, A system reboot may be happend if required':}
      exec {'system_reboot':
        command   => 'reboot -f; sleep 60',
        logoutput => true,
        require   => [ Network_config[$vrouter_physical_interface],
                        Network_config[$vrouter_interface] ],
        onlyif    => 'grep System.restart.required /var/run/reboot-required',
      }
    }

  }


  ##
  # NOTE: below scripts are taken from contrail-vrouter-init package. It may
  # need to be packaged in future.
  # The package install those scritps under /opt/contrail/bin, for now, these
  # are added in /usr/local/bin
  ##
  file {'/usr/local/bin/vrouter-functions.sh':
    ensure => file,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/vrouter-functions.sh",
    before => Exec['network_restart'],
  }

  file {'/usr/local/bin/if-vhost0':
    ensure => file,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/if-vhost0",
    before => Exec['network_restart'],
  }

  ##
  # This was agent_param earlier, but upstream module has agent_param.tmpl need
  # to be confirmed
  ##
  file { '/etc/contrail/agent_param':
    ensure => file,
    owner => root,
    group => root,
    mode => '0644',
    content => template('contrail/agent_param.erb'),
    require => Package['contrail-vrouter-agent'],
    notify => Service['contrail-vrouter-agent'],
  }

  ##
  # Upstream module has rpm_agent.conf - need to be confirmed
  ##

# NOTE UPSTREAM MODULE HAS VNC_API_LIB.INI file which is not added here. It
# seems that is for supervisor or something else.

  if $vrouter_ip {
    file { '/etc/contrail/agent.conf':
      ensure => file,
      owner => root,
      group => root,
      mode => '0644',
      content => template('contrail/agent.conf.erb'),
      require => Package['contrail-vrouter-agent'],
      notify => Service['contrail-vrouter-agent'],
    }

    file { '/etc/contrail/default_pmac':
      ensure => file,
      owner => root,
      group => root,
      mode => '0644',
      content => $vrouter_mac,
      require => Package['contrail-vrouter-agent'],
      notify => Service['contrail-vrouter-agent'],
    }

    file { '/etc/contrail/contrail-vrouter-agent.conf':
      ensure => file,
      owner => root,
      group => root,
      mode => '0644',
      content => template('contrail/contrail-vrouter-agent.conf.erb'),
      require => Package['contrail-vrouter-agent'],
      notify => Service['contrail-vrouter-agent'],
    }
  }

  file { '/etc/contrail/vrouter_nodemgr_param':
    ensure => file,
    owner => root,
    group => root,
    mode => '0644',
    content => "DISCOVERY=${discovery_ip}\n",
    require => Package['contrail-vrouter-agent'],
    notify => Service['contrail-vrouter-agent'],
  }

  file { '/var/crash':
    ensure => directory,
    owner => root,
    group => root,
    mode => '0755',
  }

  sysctl::value { 'kernel.core_pattern': value => '/var/crash/core.%e.%p.%h.%t'
}
  sysctl::value { 'net.ipv4.ip_forward': value => 1 }

  service { 'contrail-vrouter-agent':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
  }

  ##
  # Provision Contrail vrouter
  ##

  contrail_vrouter {$::hostname:
    ensure             => present,
    host_address       => $vrouter_ip,
    admin_password     => $keystone_admin_password,
    api_server_address => $api_ip_orig,
  }

}
