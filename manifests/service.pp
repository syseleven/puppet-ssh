# Class: ssh::service
#
class ssh::service () {
  service { $ssh::service:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}

