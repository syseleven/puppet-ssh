# Class ssh::export_keys
#
# This class export authorized keys for specific users which can be imported
# into /root/.ssh/authorized_keys
#
# Parameters:
#   $default_export_tag
#     Tag to export the keys to. Also for grouping keys, e.g. sys11_admins or smith_admins.
#     Could be overwritten per key by using attribute tag: NEW_GROUP.
#   $export_keys
#     hash of authorized keys to be exported
#
# Sample Usage:
#   ssh::export_keys:
#     default_export_tag: sys11_admins
#     export_keys:
#        'root_sandres':
#          key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
#          type: rsa
#        'root_cglaubitz':
#          key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
#          tag: smith_admins
#        'root_root': ### no kidding
#          key: AAAAB3NzaC1yc2EAAAABIwAAAQEA5rKU2+4WlWxSoXg22Vciq88yxxr22LdAGD8HSPjOQfDxRvdIPJ4EDu6sqesehpJdOoSvOj+lxX8YbIqORpQlqBVRV7sUdiYGTRGgb7jBuPZFTVpl/Q5mIsFuv1odWwx3A12JrniQlo2GtJ/R7v0Y9JWdYsRB5QNW8Zx6pceu/UJM66lsvvFk8N2SzZGr2TWJDOrWvkicTTTynKHF37Znn+wbRJOQEm4jYLW1IXHz/6/StD+pPcn0QMjt1t4ixxXv9F+Xo3nDpKsXd0qGbvvfzBJAC7y/0y6QT2n9xyz1qr69uyaz/WDD/sRVROyLFKBDl2CxplFN2if/Wu1QhyP9qw==
#          type: rsa
#
# To use exported keys:
#   ssh::authorized_keys:
#     import_root:
#       - smith_admins
#       - sys11_admins
#
class ssh::export_keys (
  $default_export_tag,
  $export_keys,
) {
  # define manage_export_keys:
  #
  # Parameters:
  #   export_keys
  #     Hash of hashs :-O
  #   default_export_tag:
  #     See documentation of ssh::export_keys::default_export_tag
  #
  define manage_export_keys($export_keys, $default_export_tag) {
    if $export_keys[$name]['type'] {
      $key_type = $export_keys[$name]['type']
    } else {
      $key_type = 'rsa'
    }

    if $export_keys[$name]['tag'] {
      $export_tag = $export_keys[$name]['tag']
    } else {
      $export_tag = $default_export_tag
    }

    if $export_keys[$name]['ensure'] {
      $ensure = $export_keys[$name]['ensure']
    } else {
      $ensure = 'present'
    }

    if $export_keys[$name]['user'] {
      $user = $export_keys[$name]['type']
      $comment = $name
    } elsif $name =~ /^([^_]+)_(.*)$/ {
      $user = $1
      $comment = $2
    } else {
      $user = $name
      $comment = $name
    }

    @@ssh_authorized_key_sys11 { $name:
      ensure => $ensure,
      user   => $user,
      key    => $export_keys[$name]['key'],
      type   => $key_type,
      name   => $comment,
      tag    => "${::puppet_environment}$export_tag",
      }
  }

  $user_names = keys($export_keys)
  manage_export_keys { $user_names:
    export_keys        => $export_keys,
    default_export_tag => $default_export_tag,
  }

}
