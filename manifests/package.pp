# Class: ssh::package
#
class ssh::package (
  $version,
) {

  if $::operatingsystem == 'Gentoo' {
    # package version and mask
    if $ssh::gentoo_useflags {
      gentoo::useflag { $ssh::package:
        flags   => $ssh::gentoo_useflags,
        version => $version,
      }
    }

    if $version and $version != 'installed' and $version != 'latest' {
      gentoo::packagemask { $ssh::package:
        version => $version,
        before  => Package[$ssh::package],
      }
    }
  }

  package { $ssh::package:
    ensure => $version,
    alias  => 'ssh',
  }
}
