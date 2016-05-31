node default {

  host {
      $::fqdn:
  		ensure => 'present',
  		ip     => '127.0.0.1';
  }

  class { 'puppetdb::globals':
    version => '4.1.0-1puppetlabs1',
  }

  class { 'puppetdb':
    database_host      => 'hostname',
    database_username  => 'user',
    database_password  => 'pass',
    database_port      => '5432',
    manage_dbserver    => false,
    manage_db          => false,
    listen_address     => '0.0.0.0',
    disable_ssl        => false,
    ssl_set_cert_paths => true,
    ssl_dir            => '/etc/puppetlabs/puppetdb/ssl',
    ssl_cert_path      => '/etc/puppetlabs/puppetdb/ssl/public.pem',
    ssl_key_path       => '/etc/puppetlabs/puppetdb/ssl/private.pem',
    ssl_ca_cert_path   => '/etc/puppetlabs/puppetdb/ssl/ca.pem'
  }

  class { '::puppet':
    server                      => true,
    server_foreman              => false,
    server_passenger            => false,
    server_reports              => 'puppetdb',
    server_storeconfigs_backend => 'puppetdb',
    server_external_nodes       => '',
    server_package              => 'puppetserver',
    client_package              => 'puppet-agent',
  }
  exec {'puppetdb ssl setup':
    command => "puppetdb ssl-setup",
    user    => root,
    onlyif  => "test ! -f /etc/puppetlabs/puppetdb/ssl/private.pem",
    path    => ['/usr/bin','/usr/sbin','/bin','/sbin', '/opt/puppetlabs/bin'],
    require => [Package['puppetdb'], Exec['puppet_server_config-generate_ca_cert']],
    notify  => Service['puppetdb'],
  }
  class { '::puppetdb::master::config':
    puppetdb_server     => $::fqdn,
    manage_storeconfigs => false,
    restart_puppet      => true,
  }

  Host[$::fqdn] -> Class['::Puppet'] -> Class['Puppetdb']
  Exec['puppetdb ssl setup'] -> Class['::Puppetdb::Master::Config']
}
