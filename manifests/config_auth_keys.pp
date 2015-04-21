# Class ssh:config_auth_keys
#
# just hold the configration for ssh::authorized_keys
# If this is used, the PuppetDB-import of keys is disabled
#
# We can load ssh::config_auth_keys without any impact on each node. The
# magick is defined in ssh::authorized_keys, but only if ssh::config_auth_keys
# is defined for a node!
#
# To it is possible to load this in upper roles like hardwarenode_base.
#
# This is currently just a dirty hack, since we do not have such a thing like
# hiera.
#
# Parameters
#  $authorized_keys:
#    hash of groups and ssh public keys
#    See "Sample Usage"
#
# Sample Usage
#  classes:
#    ssh::config_auth_keys:
#      authorized_keys:
#        sys11_admins:
#          root_cglaubitz:
#            type: rsa
#            key: AAAAB3NzaC1yc2EAAAADAQABAAABAQC2JRoNkeHXyDUaPZDOTLnzJOf2ata1pYTBLZaNQlONcH2yheIdfLro/jtaXxesmb6B32xItUVhMu60iEz5fpojkUeCX6DDybXvGDQv1uPVIDlun3vsbdKQrgolquUnjpVDWXI7VnzpeblA8rj9RjLx9ORGUER7t2xn4DrdIfcNo5G6kUWqiiFVouB/dMlwK9tltGcMfIeBTHK65OEEZieVXKWE9MmkTzCJpT8cYAE0/NAyN1ONME73bMPzPhTq4SQyoGf78LEvqfvILHAWxcRHqDt1ekKb/kYzRaSljWxGAuT6M7UShp89e/uP/SbCp/K5QBMpMiZQEj96zXfMXBAj
#
class ssh::config_auth_keys($authorized_keys) {
  # DO NOT REMOVE THIS!!!
  # NEEDED IN ssh::authorized_keys
}
