# define manage_authorized_keys:
#
# Parameters:
#   authorized_keys
#     Hash of hashs :-O
#
define ssh::manage_authorized_keys($authorized_keys) {
  if $authorized_keys[$name]['type'] {
    $key_type = $authorized_keys[$name]['type']
  } else {
    $key_type = 'rsa'
  }

  if $authorized_keys[$name]['ensure'] {
    $ensure = $authorized_keys[$name]['ensure']
  } else {
    $ensure = 'present'
  }

  if $authorized_keys[$name]['user'] {
    $user = $authorized_keys[$name]['user']
    $comment = $name
  } elsif $name =~ /^([^_]+)_(.*)$/ {
    $user = $1
    $comment = $2
  } else {
    $user = $name
    $comment = $name
  }

  ssh_authorized_key_sys11 { $name:
    ensure => $ensure,
    user   => $user,
    key    => $authorized_keys[$name]['key'],
    type   => $key_type,
    name   => $comment,
  }
}

