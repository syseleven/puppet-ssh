# Class: ssh
#
# Module to install and manage the openssh server. Supporting sshd_config management.
#
# Parameters:
#   $package = $ssh::params::package,
#     Package name e.g. net-misc/openssh for Gentoo, default see ssh::params.
#   $service = $ssh::params::service,
#     The service name, e.g. sshd for Gentoo, default see ssh::params.
#   $start_cmd = $ssh::params::start_cmd,
#     Start command to use instead of rc-service $service start, default see ssh::params.
#   $version = 'installed',
#     Version to install.
#   $gentoo_useflags = '',
#     Special useflags for Gentoo.
#   $listen_ip = 'internal',
#     give ip address or 'internal' or 'external', can be single one or a list
#   $listen_port = $ssh::params::port
#     sshd should listen to this port, default see ssh::params.
#   $subsystem_sftp = $ssh::params::subsystem_sftp,
#     sftp subsystem to use, default see ssh::params.
#     Will be overwritten if server_sftp_roots is used.
#   $global_known_hosts = $ssh::params:global_known_hosts_file
#     Full path to global ssh_known_hosts. Almost everywhere the default, default see ssh::params.
#   $manage_server = true,
#     True, for managing sshd_config by this module.
#   $server_x11forwarding = false,
#     Enable/disable X11Forwarding, man sshd_config.
#   $server_noneenabled = false,
#     Enable/disable NoneEnabled. This enables/disables encryption.
#   $server_passwordallowed = false,
#     Enable/disable wheter sshd asks for password or not. man sshd_config. Sets
#     UsePAM yes/no
#     PasswordAuthentication yes/no
#     ChallengeResponseAuthentication yes/no
#   $server_rootallowed = true,
#     Enable/disable root login via ssh
#   $server_template_vars = undef,
#     Userdefined sshd_config parameters. Other than the mentioned above.
#   $server_sftp_chroots = undef,
#     List of user, chroot dir hashes. This module acually does not care whether
#     the given user and/or home directory exists or not.
#   $server_usepam = undef,
#     UsePAM might be set to yes even with passwordallowed false
#   $server_host_keys  = [ '/etc/ssh/ssh_host_dsa_key' ],
#     List of HostKeys, See man sshd_config.
#   $server_ciphers = undef,
#     List of supported ciphers,
#   $server_macs = undef,
#     List of supported MACs.
#   $server_kexalgorithms = undef,
#     List of supported kexalgorithms. There is also the default_201411 preset which enables all legacy kexalgorithms pre openssh 6.7.  If undefined, set to standard openssh 6.7 kexalgorithms, which omits a lot of insecure kexalgorithms.
#   $monit_check = 'present',
#     or 'absent' to remove check
#   $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
#   $fail2ban_check = 'present',
#   $fail2ban_maxretry = 10,
#   $fail2ban_findtime = 600,
#   $fail2ban_bantime = 600,
#
# Sample usage:
#   Setting sshd_configs LoginGraceTime to 60 via server_template_vars
#
#   classes:
#     ssh:
#       server_template_vars:
#         LoginGraceTime: 60
#
#   Results to:
#   LoginGraceTime 60
#
#   Using server_sftp_chroots:
#
#   classes:
#     ssh:
#       server_sftp_chroots:
#         testuser1: /SOME/WHERE/testuser1 ## /SOME/WHERE must belong to root, testuser1/ to testuser1
#         testuser2: ## Automatically using /home/testuser2
#    Within users home directory, a directors .ssh/ and one other directory (e.g. testuser2) should
#    be created and given permission to, manually.
#
class ssh (
  $package = $ssh::params::package,
  $service = $ssh::params::service,
  $start_cmd = $ssh::params::start_cmd,
  $version = 'installed',
  $gentoo_useflags = '',
  $listen_ip = 'internal',
  $listen_port = $ssh::params::port,
  $subsystem_sftp = $ssh::params::subsystem_sftp,
  $global_known_hosts = $ssh::params::global_known_hosts_file,
  $manage_server = true,
  $server_x11forwarding = false,
  $server_noneenabled = false,
  $server_passwordallowed = false,
  $server_rootallowed = true,
  $server_template_vars = undef,
  $server_sftp_chroots = undef,
  $server_usepam = undef,
  $server_host_keys  = [ '/etc/ssh/ssh_host_dsa_key' ],
  $server_ciphers = undef,
  $server_macs = undef,
  $server_kexalgorithms = undef,
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
  $fail2ban_check = 'present',
  $fail2ban_maxretry = 10,
  $fail2ban_findtime = 600,
  $fail2ban_bantime = 600,
) inherits ssh::params {

  # pp-909 if we have a list of sftp_chroots, we have to use internal-sftp,
  # no matter what is configured via params
  if $server_sftp_chroots {
    $_subsystem_sftp = 'internal-sftp'
  } else {
    $_subsystem_sftp = $subsystem_sftp
  }

  anchor { 'ssh::start': }->
  class { 'ssh::package': }->
  class { 'ssh::server::config':
    x11forwarding   => $server_x11forwarding,
    noneenabled     => $server_noneenabled,
    passwordallowed => $server_passwordallowed,
    rootallowed     => $server_rootallowed,
    template_vars   => $server_template_vars,
    subsystem_sftp  => $_subsystem_sftp,
    sftp_chroots    => $server_sftp_chroots,
    usepam          => $server_usepam,
    host_keys       => $server_host_keys,
    ciphers         => $server_ciphers,
    macs            => $server_macs,
    kexalgorithms   => $server_kexalgorithms,
  }->
  class { 'ssh::service':
    subscribe => Class['ssh::package', 'ssh::server::config'],
  }->
  class { 'ssh::nagioscheck':
    service           => $service,
    listen_port       => $listen_port,
    monit_check       => $monit_check,
    monit_tests       => $monit_tests,
    fail2ban_check    => $fail2ban_check,
    fail2ban_maxretry => $fail2ban_maxretry,
    fail2ban_findtime => $fail2ban_findtime,
    fail2ban_bantime  => $fail2ban_bantime,
  }->
  anchor { 'ssh::end': }
}
