# == Class: contrail
#
# This class to setup opencontrail.
#
# === Parameters
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
) {

  ##
  ## contrail::system_config does operating system parameter changes,
  ##       and make the system ready to run contrail services
  ##

  include ::contrail::system_config
}
