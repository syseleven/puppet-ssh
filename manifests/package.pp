# Class: ssh::package
#
# Package definition for sshd, supporting Solaris and Linux.
# The Solaris stuff ships an own openssh package.
#
# Parameters:
#   none
#
class ssh::package () {

  if $::operatingsystem == 'Gentoo' {

    if $ssh::gentoo_useflags {
      gentoo::useflag { $ssh::package:
        flags   => $ssh::gentoo_useflags,
        version => $ssh::version,
      }
    }
  }

# kind of broken since pp-824, not needed anymore, please remove this code if proven to be not needed
# pp-942
# if $::operatingsystem == 'Solaris' {
#      file { 'openssh':
#        source => "puppet:///modules/$module_name/OpenSSH-OpenSSH_5.8p2-Solaris-i386.pkg",
#        path   => '/var/spool/pkg/OpenSSH.pkg',
#      }
#      exec {'/bin/bash -c "(echo all;yes)|pkgadd -d /var/spool/pkg/OpenSSH.pkg"':
#        subscribe   => File['openssh'],
#        refreshonly => true,
#        notify      => [Service['opensshd'], Exec['disable_system_sshd']],
#        path        => ['/usr/bin','/bin','/sbin/','/usr/sbin']
#      }
#  } else {

  if $::operatingsystem != 'Solaris' {
    package { $ssh::package:
      ensure => $ssh::version,
      alias  => 'ssh',
    }
  }

}
