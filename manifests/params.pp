# Class: ssh::params
#
# Set parameters for different OSes
#
# Parameters:
#   $listen_ip = 'internal',
#     sshd should listen to this ip, default internal. If use internal or extrenal, ip will be calculated "magickally".
#     you can also specify a list of listen_ip's to let sshd listen on more than one address. "internal" and "external"
#     are replaced in the list with the same "magickally" thing.
#   $listen_port = '22',
#     sshd should listen to this port, default see 22.
#   $confd = '/etc/ssh',
#     Base dir, that contains sshd_config. Because e.g. MacOS use /etc/sshd_config
#   $global_known_hosts = '/etc/ssh/ssh_known_hosts'
#     Full path to global ssh_known_hosts. Almost everywhere the default.
#
class ssh::params (
  $listen_ip = 'internal',
  $listen_port = '22',
  $address_family = 'inet',
  $confd = '/etc/ssh',
  $global_known_hosts = '/etc/ssh/ssh_known_hosts',
) {

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
