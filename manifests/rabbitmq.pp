##
class contrail::rabbitmq {
  class {'::rabbitmq':
    port => 5672,
    manage_repos => false,
    admin_enable => false,
  }
}
