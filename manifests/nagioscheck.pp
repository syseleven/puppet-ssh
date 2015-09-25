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
) inherits ssh::params {

  if defined(Class['nagios::nrpe']) {
    if ($listen_port == '22') {
      nagios::register_hostgroup {'ssh': }
    }
    else {
      nagios::register_hostgroup {"ssh$listen_port": }
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
}

