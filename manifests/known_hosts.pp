# Class ssh::known_hosts
#
# WARNING: if you use this class without prior using the main ssh class, sshd will be fully
# configured and started.
#
# Manage global ssh_known_hosts of sshd.
#  * manually
#  * import external resource by explicit tag
#  * export external resource by explicit tag
#
# Parameters:
#   $known_hosts = undef,
#     Hash of known hosts
#   $import = false,
#     Name of tag for external resource. Will be prepended by environment automatically. e.g. productionYOURCHOICE.
#   $export = false,
#     Name of tag for external resource. Will be prepended by environment automatically. e.g. productionYOURCHOICE.
#   $hostname = $sys11name,
#     Hostname.
#   $purge = true,
#     Purge all entries not defined by this class. Local changes as well.
#   $host_aliases_use_internal_address = false,
#     Add internal IP address to exported ssh known host
#   $host_aliases_use_external_address = false,
#     Add external IP address to exported ssh known host
#     Use internal and external = true if you want both in aliases.
#
class ssh::known_hosts (
  $known_hosts = undef,
  $import = false,
  $export = false,
  $hostname = $sys11name,
  $purge = true,
  $host_aliases_use_internal_address = false,
  $host_aliases_use_external_address = false,
) inherits ssh {
  # define manage_known_hosts:
  #
  # Parameters:
  #   known_hosts
  #     Hash of hashes :-O
  #
  define manage_known_hosts($known_hosts) {
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

  # define manage_import_known_hosts:
  #
  # Parameters:
  #   none
  #
  define manage_import_known_hosts() {
    Sshkey <<| tag == "${::puppet_environment}${name}" |>>
  }

  # working around PUP-1177
  file { $ssh::global_known_hosts:
    ensure => file,
    mode   => '0444',
  }

  if $known_hosts {
    $host_key_keys = keys($known_hosts)
    manage_known_hosts { $host_key_keys:
      known_hosts => $known_hosts,
    }
  }

  if $export {
    $export_tag = "${::puppet_environment}${export}"
    if (0 + $ssh::listen_port) == 22 {
      # most ugly hack ever seen, but we need it because kvm_hosts listen on 0.0.0.0
      $listen_port = ''
      $alias_begin =  ''
      $alias_end =  ''
    } else {
      $listen_port = ":${ssh::listen_port}"
      $alias_begin =  '['
      $alias_end =  ']'
    }

    if $host_aliases_use_internal_address and ! $host_aliases_use_external_address {
      if ! $::ipaddress_internal {
        fail('missing fact ipaddress_internal')
      }
      $host_aliases =  ["${alias_begin}${::ipaddress_internal}${alias_end}${listen_port}", "${alias_begin}${hostname}${alias_end}${listen_port}"]

    } elsif ! $host_aliases_use_internal_address and $host_aliases_use_external_address {
      if ! $::ipaddress_external {
        fail('missing fact ipaddress_external')
      }
      $host_aliases =  ["${alias_begin}${::ipaddress_external}${alias_end}${listen_port}", "${alias_begin}${hostname}${alias_end}${listen_port}"]

    } elsif $host_aliases_use_internal_address and $host_aliases_use_external_address {
      if ! $::ipaddress_internal or ! $::ipaddress_external {
        fail("missing fact ipaddress_internal ('${::ipaddress_internal}') or ipaddress_external ('${::ipaddress_external}')")
      }
      $host_aliases =  ["${alias_begin}${::ipaddress_external}${alias_end}${listen_port}", "${alias_begin}${::ipaddress_internal}${alias_end}${listen_port}", "${alias_begin}${hostname}${alias_end}${listen_port}"]
    } else {
      if $ssh::listen_ip == '0.0.0.0' {
        $host_aliases = ["${alias_begin}${hostname}${alias_end}${listen_port}"]
      } else {
        $host_aliases = ["${alias_begin}${ssh::listen_ip}${alias_end}${listen_port}", "${alias_begin}${hostname}${alias_end}${listen_port}"]
      }
    }

    @@sshkey { "${hostname}-dsa":
      type         => 'dsa',
      key          => $::sshdsakey,
      tag          => $export_tag,
      host_aliases => $host_aliases,
    }

    @@sshkey { "${hostname}-rsa":
      type         => 'rsa',
      key          => $::sshrsakey,
      tag          => $export_tag,
      host_aliases => $host_aliases,
    }
  }

  if $import {
    manage_import_known_hosts { $import: }
  }

  if $purge {
    resources { 'sshkey':
      purge => true
    }
  }

}
