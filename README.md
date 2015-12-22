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
    $gentoo_useflags = '',
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


## Ssh::remotehost

Allows a custom remotehost ssh config to be set up, for example /root/.ssh/config.

### Parameters

    $unix_user = 'root',
    $remote_hostname = undef,
    $remote_username = 'root',
    $remote_port = 22,
    $remote_privatekey = undef
      Content of the private key to use
    $remote_connecttimeout = 20,
    $ssh_config_dir = undef,
    $operation = 'add',
      add or delete the entry

### Sample Usage

    classes:
      ssh:
        remotehost:
          'nsa':
            remote_username: 'edward'
            remote_privatekey: 'ehurlghwelrghurelgheurliwgherilgheuiwlgheurilgherlghquerilghledward'
            remote_hostname: 'echolon.nsa.gov'

## Ssh::authorized_keys

Manage authorized_keys.

    classes:
      ssh::authorized_keys:
        purge: true
        import_root:
          - sys11_admins

Import all ssh public keys named sys11_admins into /root/.ssh/authorized_keys.
If your Node implements the class ssh::config_auth_keys as well, this keys will be used.

e.g.

    classes:
      ssh::config_auth_keys:
        authorized_keys:
          sys11_admins:
            'root_admin1':
              type: ssh-rsa
              key: AA...
            'root_admin2':
              type: ssh-dss
              key: AA...
          backupserver:
            'root_nfs-backup01.blu1.syseleven.de':
              type: ssh-rsa
              key: AA..

Where sys11_admins and backupserver are the group names, to be used as import_root.
We created a class sys11_ssh_keys, that we load on highest level as possible.
We use it on hardwarenode_base and virtuozzo_ve. This Class does pretty much nothing,
expect of holding the configuration for ssh::authorized_keys. So this class does
not affect any configuration, as long as ssh::authorized_keys ist not used.

You can import separate keys as well, or remove keys explicitly.

    classes:
      ssh::authorized_keys:
        purge: true
        import_root:
          - sys11_admins
        authorized_keys:
          'root_someoneskey':
            key: AA...
            type: rsa
          'root_obsoletekey':
            key: AA...
            type: rsa
            ensure: absent

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

