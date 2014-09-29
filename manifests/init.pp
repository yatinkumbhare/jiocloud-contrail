# == Class: contrail
#
# This class to setup opencontrail.
#
# === Parameters
#
# [*control_ip_list*]
#   An array of contrail control node IP list
#
#
# === Examples
#
#  include  contrail
#
# === Authors
#
# Harish Kumar <hkumar@d4devops.org>
#
#

class contrail (
  $control_ip_list = [$::ipaddress],
) {

  ##
  ## Declaring anchors
  ##
  anchor {'contrail::start':}
  anchor {'contrail::end_base_services':
    before  => Anchor['contrail::end'],
    require => Anchor['contrail::start'],
  }
  anchor {'contrail::end':}

  ##
  ## contrail::system_config does operating system parameter changes,
  ##       and make the system ready to run contrail services
  ##

  include ::contrail::system_config

  Anchor['contrail::start'] ->
  Class['contrail::system_config'] ->
  Anchor['contrail::end_base_services']

  ##
  ## Manage contrail ifmap
  ##
  class {'contrail::ifmap':
    control_ip_list => $control_ip_list
  }

  Anchor['contrail::start'] ->
  Class['contrail::system_config'] ->
  Anchor['contrail::end_base_services']
}
