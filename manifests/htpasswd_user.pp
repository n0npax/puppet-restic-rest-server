define restic_rest_server::htpasswd_user (
  $password = undef,
  $data_path,
)
{
  htpasswd { $name:
    cryptpasswd => ht_sha1($password),
    target     => "${data_path}/.htpasswd",
    notify     => Service['rest-server'],
  }

}

