# define manage_config_auth_keys
#
# Parameters:
#   $authorized_keys
#     hash of groups and ssh public keys
#     See ssh::config_auth_keys "Sample Usage"
define ssh::manage_config_auth_keys($authorized_keys) {
  if $authorized_keys[$name] {
    $host_key_keys = keys($authorized_keys[$name])
    ssh::manage_authorized_keys { $host_key_keys:
      authorized_keys => $authorized_keys[$name],
    }
  }
}

