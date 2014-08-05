class contrail::haproxy {
  # Install package
  package {'haproxy':
    ensure => present,
  }

  ##Configure haproxy
  file { "/etc/haproxy/haproxy.cfg":
    ensure  => present,
    mode => 0755,
    owner => root,
    group => root,
    content => template("contrail/haproxy.cfg.erb")
  }

  file {'/etc/default/haproxy':
    ensure  => present,
    mode => 0755,
    owner => root,
    group => root,
    content => 'ENABLED=1',
    require => File["/etc/haproxy/haproxy.cfg"]
  }

  service { "haproxy" :
    enable => true,
    require => [File["/etc/default/haproxy"],
                File["/etc/haproxy/haproxy.cfg"]],
    ensure => running
  }
}
