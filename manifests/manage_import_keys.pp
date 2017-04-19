#
define ssh::manage_import_keys() {
  Ssh_authorized_key_sys11 <<| tag == "${::environment}${name}" |>>
}

