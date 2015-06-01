# Class: ssh
#
class ssh (
  $package = $ssh::params::package,
  $service = $ssh::params::service,
  $start_cmd = $ssh::params::start_cmd,
  $version = 'installed',
  $gentoo_useflags = '',
  $listen_ip = 'internal',
  $listen_port = $ssh::params::port,
  $address_family = $ssh::params::address_family,
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
