# Class: ssh::package
#
class ssh::package () {

  if $::operatingsystem == 'Gentoo' {

    # package version and mask
    case $ssh::version {
      # approved version by sys11 #pp-2530
      'latest_sys11': {
        $version_real = '6.9_p1-r2'
        $version_mask = $version_real
      }
      /installed|latest|absent/: {
        $version_real = $ssh::version
        $version_mask = undef
      }
      default: {
        $version_real = $ssh::version
        $version_mask = $version_real
      }
    }

    if $ssh::gentoo_useflags {
      gentoo::useflag { $ssh::package:
        flags   => $ssh::gentoo_useflags,
        version => $version_real,
      }
    }

    gentoo::packagemask { $ssh::package:
      version => $version_mask,
      before  => Package[$ssh::package],
    }

  } else {

    $version_real = $ssh::version

  }

  if $::operatingsystem != 'Solaris' {
    package { $ssh::package:
      ensure => $ssh::version_real,
      alias  => 'ssh',
    }
  }

}
