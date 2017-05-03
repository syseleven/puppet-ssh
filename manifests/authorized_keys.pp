# Class ssh::authorized_keys
#
# This class deploys authorized keys for specific users
#
# Parameters:
#   $authorized_keys = undef
#     hash of authorized keys to be deployed
#   $purge = false
#     Only purges root's authorized_keys.
#     Be careful, if purge == true and no keys are specified or imported,
#     /root/.ssh/authorized_keys will be empty.
#     KNOWN TO BE COMPLICATED http://projects.puppetlabs.com/issues/1581
#
# Sample Usage:
#   ssh::authorized_keys:
#     purge: true
#     authorized_keys:
#        'root_sandres':
#          key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
#          type: rsa
#        'root_cglaubitz':
#          key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
#        'root':
#          key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
#          ensure: absent
#
class ssh::authorized_keys (
  Hash    $authorized_keys,
  Boolean $purge = false, ####### Should be false, since it is possible empty roots authorized_keys ########
) {

  $authorized_keys.each |$keyname,$values| {
    $key_type = $values['type'] ? {
      undef   => 'rsa',
      default => $values['type'],
    }

    $ensure = $values['ensure'] ? {
      undef   => 'present',
      default => $values['ensure'],
    }

    if $values['user'] {
      $user = $values['user']
      $comment = $keyname
    } elsif $keyname =~ /^([^_]+)_(.*)$/ {
      $user = $1
      $comment = $2
    } else {
      $user = $keyname
      $comment = $keyname
    }

    ssh_authorized_key_sys11 { $keyname:
      ensure => $ensure,
      user   => $user,
      key    => $values['key'],
      type   => $key_type,
      name   => $comment,
    }
  }

  if $purge and ! defined(Resources['ssh_authorized_key_sys11']) {
    resources { 'ssh_authorized_key_sys11':
      purge => true
    }
  }
}

