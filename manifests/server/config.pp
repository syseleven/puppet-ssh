# class ssh::server::config() {
#
# Parameters:
#   $x11forwarding
#     Enable/disable X11Forwarding, man sshd_config.
#   $noneenabled = false,
#     Enable/disable NoneEnabled. This enables/disables encryption.
#   $passwordallowed
#     Enable/disable wheter sshd asks for password or not. man sshd_config. Sets
#     UsePAM yes/no
#     PasswordAuthentication yes/no
#     ChallengeResponseAuthentication yes/no
#   $usepam
#     UsePAM might be set to yes even with passwordallowed false
#   $rootallowed
#     Enable/disable root login via ssh
#   $template_vars = undef,
#     Userdefined sshd_config parameters. Other than the mentioned above.
#   $subsystem_sftp
#     Setting Subsystem to $subsystem_sftp. Be careful. $subsystem_sftp must
#     correspodent to $sftp_chroots
#   $sftp_chroots
#     List of user, home dir hashes.
#   $host_keys
#     List of HostKeys, See man sshd_config.
#   $ciphers = undef,
#     List of supported ciphers,
#   $macs = undef,
#     List of enabled MACs.
#   $kexalgorithms = undef,
#     List of enabled KexAlgorithms
#
class ssh::server::config(
  $x11forwarding,
  $passwordallowed,
  $noneenabled,
  $rootallowed,
  $template_vars,
  $subsystem_sftp,
  $sftp_chroots,
  $host_keys,
  $usepam,
  $ciphers,
  $macs,
  $kexalgorithms,
) {

  $real_kexalgorithms = $kexalgorithms ? {
    'default_201411' => 'curve25519-sha256@libssh.org,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group-exchange-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521',
    default          => $kexalgorithms,
  }

  if $passwordallowed and $usepam != undef {
    notify { 'The parameter usepam will be ignore because of passwordallowed := true': }
  }
  # ssh/sshd_config.erb will include ssh/sshd_sftp_chroots if $sftp_chroots
  # is set.
  file{'sshd_config':
    path    => "${ssh::confd}/sshd_config",
    content => template('ssh/sshd_config.erb'),
  }
}
