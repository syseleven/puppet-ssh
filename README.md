# SSH

* [Official documentation](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/sshd.8?query=sshd&sec=8)
* [changelog](CHANGELOG)

## Sample usage

    classes:
      ssh:

Setting sshd_configs LoginGraceTime to 60 via server_template_vars:

    classes:
      ssh:
        server_template_vars:
          LoginGraceTime: 60

Using server_sftp_chroots:

Within users home directory, a directors .ssh/ and one other directory (e.g. testuser2) should be created and given permission to, manually.

    classes:
      ssh:
        server_sftp_chroots:
          testuser1: /SOME/WHERE/testuser1 ## /SOME/WHERE must belong to root, testuser1/ to testuser1
          testuser2: ## Automatically using /home/testuser2

If you want to add more settings to a specific user you can do it like this, but keep in mind that there is no syntax check:

    classes:
      ssh:
        server_sftp_chroots:
          testuser:
            PasswordAuthentication: 'yes'

Fix for old ssh clients with error "Failed: SSHProtocolFailure: Algorithm negotiation fail":

    classes:
      ssh:
        server_kexalgorithms: 'default_201411'
        version: 'latest_sys11'

## Parameters

    $package = $ssh::params::package,
      Package name e.g. net-misc/openssh for Gentoo, default see ssh::params.
    $service = $ssh::params::service,
      The service name, e.g. sshd for Gentoo, default see ssh::params.
    $version = 'latest_sys11',
    $gentoo_useflags = undef,
      Special useflags for Gentoo.
    $listen_ip = 'internal',
      give ip address or 'internal' or 'external', can be single one or a list
    $listen_port = $ssh::params::port
      sshd should listen to this port, default see ssh::params.
    $address_family = $ssh::params::address_family,
      defaults to 'inet', see ssh::params
    $subsystem_sftp = $ssh::params::subsystem_sftp,
      sftp subsystem to use, default see ssh::params.
      Will be overwritten if server_sftp_roots is used.
    $global_known_hosts = $ssh::params:global_known_hosts_file
      Full path to global ssh_known_hosts. Almost everywhere the default, default see ssh::params.
    $manage_server = true,
      True, for managing sshd_config by this module.
    $server_x11forwarding = false,
      Enable/disable X11Forwarding, man sshd_config.
    $server_passwordallowed = $ssh::params::server_passwordallowed,
      Enable/disable wheter sshd asks for password or not. man sshd_config. Sets
      UsePAM yes/no
      PasswordAuthentication yes/no
      ChallengeResponseAuthentication yes/no
    $server_rootallowed = $ssh::params::server_rootallowed,
      Enable/disable root login via ssh
    $server_template_vars = undef,
      Userdefined sshd_config parameters. Other than the mentioned above.
    $server_sftp_chroots = undef,
      List of user, chroot dir hashes. This module acually does not care whether
      the given user and/or home directory exists or not.
    $server_usepam = undef,
      UsePAM might be set to yes even with passwordallowed false
    $server_host_keys = $ssh::params::server_host_keys,
      List of HostKeys, See man sshd_config.
    $server_ciphers = undef,
      List of supported ciphers,
    $server_macs = undef,
      List of supported MACs.
    $server_kexalgorithms = undef  
      List of supported kexalgorithms. There is also the default_201411 preset which enables all legacy kexalgorithms pre openssh 6.7.  If undefined, set to standard openssh 6.7 kexalgorithms, which omits a lot of insecure kexalgorithms.
    $monit_check = 'present',
      or 'absent' to remove check
    $monit_tests = ['if 3 restarts within 18 cycles then timeout'],
    $fail2ban_check = 'present',
    $fail2ban_maxretry = 10,
    $fail2ban_findtime = 600,
    $fail2ban_bantime = 600,
    $check_sftp_logins = true,
      Enable or disable the nagioscheck
    $sftp_logins = undef,
      The list of accounts nagios should check

## Ssh::authorized_keys

Manage authorized_keys.

    classes:
      ssh::authorized_keys:
        authorized_keys:
          root_sandres:
            key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
            type: rsa
        purge: true

## ssh::nagioscheck

This class can be called directly, if you only want do have nagios and zabbix
handled. Therefore we dont use variables from the params scope.

When using main class, use varibales in there. Vars are then passed to this
class.

### Parameters

    $service = $ssh::params::service
    $listen_port = $ssh::params::port
    $monit_check = 'present'
      or 'absent' to remove check
    $monit_tests = ['if 3 restarts within 18 cycles then timeout']
    $fail2ban_check = 'present',
    $fail2ban_maxretry = 10,
    $fail2ban_findtime = 600,
    $fail2ban_bantime = 600,
    $check_sftp_logins = true,
      Enable or disable the nagioscheck
    $sftp_logins = undef,
      The list of accounts nagios should check

