class restic_rest_server::params
{
  $version = '0.9.6' # default version
  $data_path = '/data/restic'
  $user = 'www-data'
  $group = 'www-data'
  $prometheus = false
  $tls = undef
  $tls_cert = undef
  $tls_key = undef
  $log = '/var/log/restic-rest-server.log'
  $listen = undef
  $append_only = false
  $install_unzip = true
  $restic_users = undef
}
