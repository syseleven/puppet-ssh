# define manage_import_known_hosts:
#
# Parameters:
#   none
#
define ssh::manage_import_known_hosts() {
  Sshkey <<| tag == "${::environment}${name}" |>>
}

