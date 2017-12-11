class restic_rest_server (
  $version = $restic_rest_server::params::version,
  $user = $restic_rest_server::params::user,
  $group = $restic_rest_server::params::group,
  $prometheus = $restic_rest_server::params::prometheus,
  $data_path = $restic_rest_server::params::data_path,
  $tls_cert = $restic_rest_server::params::tls_cert,
  $tls_key = $restic_rest_server::params::tls_key,
  $log = $restic_rest_server::params::log,
  $listen = $restic_rest_server::params::listen,
  $append_only = $restic_rest_server::params::append_only,
  $install_unzip = $restic_rest_server::params::install_unzip,
  $restic_users = $restic_rest_server::params::restic_users,
) inherits restic_rest_server::params

{
if $data_path {
    $data_path_option = "--path ${data_path}"
    file { $data_path:
        ensure  => directory,
        recurse => true,
        owner   => $user,
    }
}

if $tls_cert and $tls_key {
    $tls_option = '--tls --tls-cert /etc/restic/rest-server/cert --tls-key /etc/restic/rest-server/key'
    file { '/etc/restic':
        ensure => directory,
        owner  => $user,
        group  => $group,
    }
    file { '/etc/restic/rest-server':
        ensure  => directory,
        owner   => $user,
        group   => $group,
        require => File['/etc/restic'],
    }
    file { '/etc/restic/rest-server/cert':
        ensure  => file,
        owner   => $user,
        group   => $group,
        content => $tls_cert,
        require => File['/etc/restic/rest-server'],
    }
    file { '/etc/restic/rest-server/key':
        ensure  => file,
        owner   => $user,
        group   => $group,
        content => $tls_key,
        require => File['/etc/restic/rest-server'],
    }
} elsif $tls_cert or $tls_key {
    fail('You have to specify tls cert and tls key or neither')
}


if $prometheus { $prometheus_option = '--prometheus' }
if $listen { $listen_option = "--listen ${listen}" }
if $log { $log_option = "--log ${log}" }
if $append_only { $append_only_option = '--append-only' }

$options = "${data_path_option} ${prometheus_option} ${listen_option} ${log_option} ${append_only_option} ${tls_option}"

if $install_unzip {
    package {'unzip':
        ensure => latest,
    }
}
if $log {
    file { $log:
        ensure => file,
        owner  => $user,
        group  => $group,
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
  ensure  => running,
  enable  => true,
  require => [
      File['/etc/systemd/system/rest-server.service'],
      File['/usr/local/bin/rest-server'],
  ],
}
if $restic_users {
  file { "${data_path}/.htpasswd":
    ensure => file,
    owner  => $user,
    group  => $group,
    mode   => '0600',
    notify => Service['rest-server'],
  }

create_resources(restic_rest_server::htpasswd_user, $restic_users, {'data_path' => $data_path})
}

}

