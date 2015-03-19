# Class: ssh::service
#
# Service definition for sshd, supporting Solaris and Linux.
#
# Parameters:
#   none
#
class ssh::service () {

  # pp-942 let the service running though
  if $::operatingsystem == 'Solaris' {
    service {'opensshd':
      ensure    => running,
      enable    => true,
      hasstatus => false,
      alias     => 'sshd',
      pattern   => 'sshd',
      provider  => 'base',
      start     => '/etc/init.d/opensshd start',
      restart   => '/etc/init.d/opensshd restart',
    }

    exec { 'disable_system_sshd':
      path    => ['/usr/bin','/bin','/sbin/','/usr/sbin'],
      command => 'svcadm disable ssh',
      onlyif  => 'bash -c "! svcs -H svc:/network/ssh:default|grep  disabled >/dev/null"',
      require => Service['opensshd'],
    }
  } else {
    service { $ssh::service:
      ensure      => running,
      enable      => true,
      start       => $ssh::start_cmd,
      hasrestart  => true,
      hasstatus   => true,
    }
  }

}
