#
# Class: contrail::repo
#
class contrail::repo {
  case $::osfamily {
    'Debian': {
      include contrail::repo::apt
    }
    default: {
      fail("OS family ${::osfamily} is not supported")
    }
  }

}
