# define manage_known_hosts:
#
# Parameters:
#   known_hosts
#     Hash of hashes :-O
#
define ssh::manage_known_hosts($known_hosts) {
  if $known_hosts[$name]['type'] {
    $key_type = $known_hosts[$name]['type']
  } else {
    $key_type = 'dsa'
  }

  if $known_hosts[$name]['ensure'] {
    $ensure = $known_hosts[$name]['ensure']
  } else {
    $ensure = 'present'
  }

  sshkey { $name:
    ensure       => $ensure,
    name         => $name,
    key          => $known_hosts[$name]['key'],
    type         => $key_type,
    host_aliases => $known_hosts[$name]['host_aliases'],
  }
}

