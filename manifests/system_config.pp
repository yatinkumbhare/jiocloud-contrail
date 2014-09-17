##
## Class: contrail::system_config
##   To do base system configuration to host contrail control nodes
##

class contrail::system_config {

  #
  # Ensure /etc/hosts has an entry for self to map dns name to ip address
  #

  if !defined (Host[$::hostname]) {
    host { $::hostname :
      ensure => present,
      ip     => $::ipaddress
    }
  }

  ##
  ## Disable SELINUX on boot, if not already disabled for Redhat/Centos.
  ## Remove any core file limitation
  ## Disable firewall
  ##

  if ($::operatingsystem == 'Centos' or $::operatingsystem == 'Fedora') {
    ##
    ## disable selinux runtime
    ##
    exec { 'selinux_disable_runtime' :
      command  => 'setenforce 0 || true',
      unless   => 'getenforce | grep -qi disabled',
      provider => shell,
    }

    ##
    ## Make it persistant
    ##
    file_line {'contrail_selinux_disable_persistant':
      ensure => present,
      line   => 'SELINUX=disabled',
      match  => '^[\s\t]*SELINUX=',
      path   => '/etc/sysconfig/init',
    }

    service { 'iptables' :
      ensure => stopped,
      enable => false
    }

    file_line {'daemon_core_file_unlimited':
      ensure => present,
      line   => 'DAEMON_COREFILE_LIMIT=unlimited',
      match  => '^[\s\t]*DAEMON_COREFILE_LIMIT=',
      path   => '/etc/sysconfig/init',
    }
  }

  if ($::operatingsystem == 'Ubuntu') {
    ##
    ## disable firewall, service scripts are not working for this
    ##
    exec { 'disable-ufw' :
      command => 'ufw disable',
      unless  => 'ufw status | grep -qi inactive',
    }

    ##
    ## This change need reboot of system.
    ## This would also need change in /etc/pam.d if limits.so is 
    ##   not added in session
    ##

    file_line {'daemon-core-file-unlimited':
      ensure => present,
      line   => '* soft core unlimited',
      match  => '^[\s\t]*.[\s\t]*soft[\s\t]*core',
      path   => '/etc/security/limits.conf',
    }

  }

  ##
  ## Core pattern
  ##

  ::sysctl::value {'kernel.core_pattern':
    value => '/var/crashes/core.%e.%p.%h.%t'
  }

  ##
  ## Enable ip forwarding in sysctl.conf for vgw
  ##

  ::sysctl::value {'net.ipv4.ip_forward':
    value => '1'
  }

}
