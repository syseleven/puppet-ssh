# define manage_export_keys:
#
# Parameters:
#   export_keys
#     Hash of hashs :-O
#   default_export_tag:
#     See documentation of ssh::export_keys::default_export_tag
#
define ssh::manage_export_keys($export_keys, $default_export_tag) {
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
    tag    => "${::environment}${export_tag}",
  }
}

