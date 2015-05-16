#
# Define: contrail::vgw
#   To provision contrail vgw interfaces
#
define contrail::vgw (
  $subnet,
  $vrf,
  $dest_net = '0.0.0.0/0',
) {

  validate_re($title, 'vgw\d+')

  $interface = $title

  include contrail::vrouter

  ##
  # Enable ip forwarding
  ##
  ensure_resource('sysctl::value','net.ipv4.ip_forward',{'value' => 1})

  ##
  # Create vif.
  ##
  exec {"vif_create_${interface}":
    command => "vif --create ${interface} --mac 00:01:00:5e:00:00",
    unless  => "vif --list | grep ${interface}",
    notify  => Service['contrail-vrouter-agent']
  }

  ##
  # This step make vgw configuration persistant.
  # TODO: Not handling multiple subnets here. This will be look into at later point.
  ##
  network_config { $interface:
    ensure  => present,
    onboot  => true,
    method  => 'manual',
    options =>  {
                    'pre-up' => "vif --create ${interface} --mac 00:01:00:5e:00:00",
                    'up'     => "route add -net ${subnet} dev ${interface}"
                  },
    require => Exec["vif_create_${interface}"]
  }

  exec {"ifup_${interface}":
    command => "ifup ${interface}",
    unless  => "ifconfig | grep ${interface}",
    require => Network_config[$interface],
  }

  $gw_num = regsubst($interface,'vgw(\d+)','\1')

  contrail_vrouter_config {
    "GATEWAY-${gw_num}/interface":        value => $interface;
    "GATEWAY-${gw_num}/routing_instance": value => $vrf;
    "GATEWAY-${gw_num}/ip_blocks":        value => $subnet;
    "GATEWAY-${gw_num}/routes":           value => $dest_net
  }
}
