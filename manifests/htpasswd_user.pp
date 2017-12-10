define restic_rest_server::htpasswd_user (
	$password = undef,
	$htpasswd_path,
)
{
	htpasswd { $name:
	  cryptpasswd => ht_sha1($password),
	  target     => "${htpasswd_path}/.htpasswd",
	  notify => Service['rest-server'],
	}

}

