# Class: ssh::params
#
class ssh::params () {

  $listen_port = '22'
  $address_family = 'inet'
  $confd = '/etc/ssh'
  $global_known_hosts = '/etc/ssh/ssh_known_hosts'

  if ($::is_virtual == true) or ($::is_virtual == 'true') {
    $listen_ip = '0.0.0.0'
    $server_rootallowed = false
    $server_passwordallowed = false
    $server_host_keys = [ '/etc/ssh/ssh_host_dsa_key' ]
  } else {
    $listen_ip = 'internal'
    $server_rootallowed = true
    $server_passwordallowed = false
    $server_host_keys = [ '/etc/ssh/ssh_host_dsa_key' ]
  }

  case $::operatingsystem {
    'Gentoo': {
      $package = 'net-misc/openssh'
      $service = 'sshd'
      $pid = "/var/run/${service}.pid"
      $subsystem_sftp = '/usr/lib/misc/sftp-server'
    }
    'CentOS': {
      $package = 'openssh-server'
      $service = 'sshd'
      $pid = "/var/run/${service}.pid"
      $subsystem_sftp = '/usr/libexec/openssh/sftp-server'
    }
    'Debian', 'Ubuntu': {
      $package = 'openssh-server'
      $service = 'ssh'
      $pid = "/var/run/${service}d.pid"
      $subsystem_sftp = '/usr/lib/sftp-server'
    }
    'Solaris': {
      $subsystem_sftp = 'internal-sftp'
    }
    default: {
      fail("Unknown OS: $::operatingsystem")
    }
  }

  $port = $listen_port
  $global_known_hosts_file = $global_known_hosts

}

