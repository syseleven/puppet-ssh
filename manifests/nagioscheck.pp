# Class: ssh::nagioscheck
#
# This class can be called directly, if you only want do have nagios and zabbix
# handled. Therefore we dont use variables from the params scope.
#
# When using main class, use varibales in there. Vars are then passed to this
# class.
#
class ssh::nagioscheck (
  $service = $ssh::params::service,
  $listen_port = $ssh::params::port,
  $monit_check = 'present',
  $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
  $fail2ban_check = 'present',
  $fail2ban_maxretry = 10,
  $fail2ban_findtime = 600,
  $fail2ban_bantime = 600,
  $sftp_logins = undef,
  $check_sftp_logins = true,
) inherits ssh::params {
  # validate
  validate_bool ( $check_sftp_logins )

  if defined(Class['nagios::nrpe']) {
    if ($listen_port == '22') {
      nagios::register_hostgroup {'ssh': }
    }
    else {
      nagios::register_hostgroup {"ssh${listen_port}": }
    }
  }

  if defined(Class['monit']) {
    monit::check_process::process_set { $service:
      ensure => $monit_check,
      tests  => $monit_tests,
      pid    => $ssh::params::pid,
    }
  }

  if $::operatingsystem == 'gentoo' {
    include fail2ban
    fail2ban::filter::filter_set { 'sshd':
      ensure   => $fail2ban_check,
      maxretry => $fail2ban_maxretry,
      findtime => $fail2ban_findtime,
      bantime  => $fail2ban_bantime,
    }
  }

  # configure sftp checks if necessary
  if $ssh::server_sftp_chroots or $sftp_logins {
    # validate
    if $ssh::server_sftp_chroots {
      validate_hash ( $ssh::server_sftp_chroots )
    }
    if $sftp_logins {
      validate_array ( $sftp_logins )
    }

    if $check_sftp_logins {
      # deploy check
      include nagios::nrpe
      file { "${nagios::nrpe::plugindir}/check_sftp_logins":
        ensure  => present,
        owner   => 'nagios',
        group   => 'root',
        mode    => '0750',
        content => template('ssh/check_sftp_logins.erb'),
      }->
      file { "${nagios::nrpe::plugindir}/check_sftp_login.py":
        ensure => present,
        owner  => 'nagios',
        group  => 'root',
        mode   => '0750',
        source => 'puppet:///modules/ssh/check_sftp_login.py',
      }

      # ensure existing keypair
      file { "$nagios::params::nagios_home/.ssh":
        ensure => directory,
        owner  => 'nagios',
        group  => 'root',
        mode   => '0750',
      }->
      exec { 'create_nagios_ssh_key':
        command => "ssh-keygen -b2048 -f $nagios::params::nagios_home/.ssh/id_rsa -N ''",
        path    => '/bin/:/sbin/:/usr/bin/:/usr/sbin/',
        unless  => "test -f $nagios::params::nagios_home/.ssh/id_rsa",
      }
      if ! defined(Nagios::Register_hostgroup['sftp-logins']) {
        nagios::register_hostgroup { 'sftp-logins': }
      }
    } else {
      if ! defined(Nagios::Hostgroup::Unregister_hostgroup['sftp-logins']) {
        nagios::hostgroup::unregister_hostgroup { 'sftp-logins':  }
      }
    }
  }
}

