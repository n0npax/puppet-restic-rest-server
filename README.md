# Puppet module to setup restic rest-server

Setup restic rest-server on node. Please see restic pages:
- [rest-server]
- [restic]

###### Tested on ubuntu 16.04 and puppet 5.3, it may work on other systems and puppet versions, but it wasn't tested at all.

## usage
example setup

class:
```puppet
$restic_users = hiera('restic::users')

class { 'restic_rest_server':
        restic_users => $restic_users,
}
```
hiera
```yaml
restic::users:
    user0:
        password: Ala-ma-kota
    user1:
        password: other-secret-password
```


### all params:
```puppet
class restic_rest_server (
  $version, # release from https://github.com/restic/rest-server/releases
  $user, # run server as $user. for example: www-data
  $group, # same as above, but group
  $prometheus, # enable prometheus
  $data_path, # --path parameter. Will create path and set permissions
  $tls_cert, # content of cert
  $tls_key, # content of private key
  $log, # log path
  $listen, # --listen argument
  $append_only, # --append-only
  $install_unzip, # module needs unzip package, you may disable installing it and install on your own
  $restic_users, # .htpasswd entries. { 'user0' > { 'password' => 'secret' }}
){
##
}
```
[//]: #
[rest-server]: <https://github.com/restic/rest-server/>
[restic]: <https://github.com/restic/restic>
