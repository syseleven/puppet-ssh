# Class: ssh::remotehost
#
# Parameters:
#   None
#
class ssh::remotehost () {

  # Define: ssh::remotehost::remotehost_set
  #
  # Parameters:
  #   $unix_user = 'root',
  #   $remote_hostname = $name,
  #   $remote_username = 'root',
  #   $remote_port = 22,
  #   $remote_privatekey = undef,
  #   $remote_connecttimeout = 20,
  #   $ssh_config_dir = undef,
  #   $operation = 'add',
  #
  define remotehost_set (
    $unix_user = 'root',
    $remote_hostname = $name,
    $remote_username = 'root',
    $remote_port = 22,
    $remote_privatekey = undef,
    $remote_connecttimeout = 20,
    $ssh_config_dir = undef,
    $operation = 'add',
  ) {

    if ! $ssh_config_dir {
      $ssh_config_dir_prefix =  $unix_user ? {
        'root'  => '/root/.ssh',
        default => "/home/${unix_user}/.ssh",
      }
    } else {
      $ssh_config_dir_prefix = $ssh_config_dir
    }

    $ssh_config_file = "${ssh_config_dir_prefix}/config"

    if $operation == 'delete' {
      $changes = [
        "rm  Host[.= \'${name}\']/*",
        "rm  Host[.= \'${name}\']",
      ]
      $actualchanges = $changes
    } else {
      $changes = [
        "set Host ${name}",
        "set Host[.= \'${name}\']/HostName ${remote_hostname}",
        "set Host[.= \'${name}\']/User ${remote_username}",
        "set Host[.= \'${name}\']/Port ${remote_port}",
      ]
      if $remote_privatekey {
        $actualchanges = [
          $changes,
          "set Host[.= \'${name}\']/IdentityFile ${name}",
        ]
      } else {
        $actualchanges = $changes
      }
    }
    
    file { "${ssh_config_dir_prefix}/${name}":
      ensure  => file,
      content => $remote_privatekey,
    }
    
    augeas { "${name}-sshconfig":
      incl    => $ssh_config_file,
      changes => $actualchanges,
      lens    => 'ssh.lns',
    }

  }

  create_resources(ssh::remotehost::remotehost_set, $ssh::remotehost)

}

  
