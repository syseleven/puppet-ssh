# Class: ssh::params
#
class ssh::params (
  $listen_port = '22',
  $address_family = 'inet',
  $confd = '/etc/ssh',
  $global_known_hosts = '/etc/ssh/ssh_known_hosts',
) {

  case $::virtual {
    'openvz': {
      $listen_ip = 'internal'
      $server_passwordallowed = true
      $server_rootallowed = true
      $server_host_keys = [ '/etc/ssh/ssh_host_dsa_key' ]
    }
    default: {
      $listen_ip = '0.0.0.0'
      $server_passwordallowed = true
      $server_rootallowed = false
      $server_host_keys = [ '/etc/ssh/ssh_host_dsa_key', '/etc/ssh/ssh_host_rsa_key', '/etc/ssh/ssh_host_ecdsa_key' ]
    }
  }

  case $::operatingsystem {
    'Gentoo': {
      $package = 'net-misc/openssh'
      $service = 'sshd'
      $subsystem_sftp = '/usr/lib/misc/sftp-server'
    }
    'CentOS': {
      $package = 'openssh-server'
      $service = 'sshd'
      $subsystem_sftp = '/usr/libexec/openssh/sftp-server'
    }
    'Debian', 'Ubuntu': {
      $package = 'openssh-server'
      $service = 'ssh'
      $subsystem_sftp = '/usr/lib/sftp-server'
    }
    'Solaris': {
      $subsystem_sftp = 'internal-sftp'
    }
    default: {
      fail("Unknown OS: $::operatingsystem")
    }
  }

  $start_cmd = "/etc/init.d/$service restart"

  $port = $listen_port
  $global_known_hosts_file = $global_known_hosts

}
