node default {

  host {
    $::fqdn:
      ensure => 'present',
      ip     => '127.0.0.1';
  }

  class { 'puppetdb::globals':
    version => '2.3.8-1puppetlabs1',
  }
  class { 'puppetdb':
    listen_address      => '0.0.0.0',
    disable_ssl         => false,
    ssl_set_cert_paths  => true,
    ssl_dir             => '/etc/puppetdb/ssl',
    ssl_cert_path       => '/etc/puppetdb/ssl/public.pem',
    ssl_key_path        => '/etc/puppetdb/ssl/private.pem',
    ssl_ca_cert_path    => '/etc/puppetdb/ssl/ca.pem'
  }
  class { '::puppet':
     server                      => true,
     server_foreman              => false,
     server_reports              => 'puppetdb',
     server_storeconfigs_backend => 'puppetdb',
     server_external_nodes       => '',
  }
  exec {'puppetdb ssl setup':
    command         => "puppetdb ssl-setup",
    user            => root,
    onlyif          => "test ! -f /etc/puppetdb/ssl/private.pem",
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    require         => [Package['puppetdb'], Exec['puppet_server_config-generate_ca_cert']],
    notify          => Service['puppetdb'],
  }
  class { '::puppetdb::master::config':
    puppetdb_server             => $::fqdn,
    manage_storeconfigs         => false,
    restart_puppet              => true,
  }

  Host[$::fqdn] -> Class['::Puppet'] -> Class['Puppetdb']
  Exec['puppetdb ssl setup'] -> Class['::Puppetdb::Master::Config']
}
