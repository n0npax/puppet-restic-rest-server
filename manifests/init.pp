class restic_rest_server (
  $version = $restic_rest_server::params::version,
  $user = $restic_rest_server::params::user,
  $group = $restic_rest_server::params::group,
  $prometheus = $restic_rest_server::params::prometheus,
  $path = $restic_rest_server::params::path,
  $tls = $restic_rest_server::params::tls,
  $tls_cert = $restic_rest_server::params::tls_cert,
  $tls_key = $restic_rest_server::params::tls_key,
  $log = $restic_rest_server::params::log,
  $listen = $restic_rest_server::params::listen,
  $append_only = $restic_rest_server::params::append_only,
  $install_unzip = $restic_rest_server::params::install_unzip,
  $restic_users = $restic_rest_server::params::restic_users,
) inherits restic_rest_server::params
{
if $path {
    $path_option = "--path ${path}"
    file { $path:
        ensure => directory,
    }
}

htpasswd { user:
  cryptpasswd => ht_sha1('password'),
  #file     => "${path}/.htpasswd",
  target     => "${path}/.htpasswd",
  notify => Service['rest-server'],
}

file { "${path}/.htpasswd":
  owner => $user,
  ensure => file,
}

## prepare list of options for systemd service
if $prometheus { $prometheus_option = '--prometheus' }
if $listen { $listen_option = "--listen ${lister}" }
if $log {  $log_option = "--log ${log}" }
if $append_only { $append_only_option = '--append_only' }
if $tls {  $tls_option = '--tls' }
if $tls_cert {     $tls_cert_option = "--tls-cert ${tls_cert}" }
if $tls_key {     $tls_key_option = "--tls-key ${tls_key}" }

$options = "${path_option} ${prometheus_option} ${listen_option} ${log_option} ${append_only_option} ${tls_option} ${tls_cert_option} ${tls_key_option}"

if $install_unzip {
   package {'unzip':
       ensure => latest,
   }
}
if $log {
    file { $log:
  owner => $user,
  ensure => file,
    }
}

wget::fetch { 'download restic rest server':
  source      => "https://github.com/restic/rest-server/releases/download/v0.9.5/rest-server-${version}-${::kernel}-${::architecture}.gz",
  destination => '/tmp/rest-server.gz',
  timeout     => 0,
  verbose     => false,
} ->
exec {'unzip rest-server binary':
  path    => '/usr/bin:/usr/sbin:/bin',
  command => '/bin/gzip -k -d /tmp/rest-server.gz; mv rest-server /usr/local/bin/',
  unless  => 'test -f /usr/local/bin/rest-server',
  require => Package['unzip'], # by default installed by this package. You may set install_uzip to false and install it on your own by other modules
} ->
file {'/usr/local/bin/rest-server':
    mode => '0711',
}

file { '/etc/systemd/system/rest-server.service':
  ensure  => file,
  content => template('restic_rest_server/rest-server.service.erb'),
  notify  => Service['rest-server']
}

service {  'rest-server':
  enable  => true,
  ensure  => 'running',
  require => [ File['/etc/systemd/system/rest-server.service'],
         File['/usr/local/bin/rest-server'],
	 File["${path}/.htpasswd"]
	],
}

}
