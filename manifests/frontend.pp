class zabbix::forntend (
  $zabbix_version                = $zabbix::params::zabbix_version,
  $zabbix_repo                   = $zabbix::params::zabbix_repo,
  $zabbix_server                 = $zabbix::params::zabbix_server,
  $zabbix_server_name            = $zabbix::params::zabbix_server_name,
  $zabbix_listenport             = $zabbix::params::server_ListenPort,
  $url                           = $zabbix::params::frontend_url,
  $type                          = $zabbix::params::zabbix_database,
  $host                          = $zabbix::params::database_host,
  $name                          = $zabbix::params::database_name,
  $schema                        = $zabbix::params::database_schema,
  $user                          = $zabbix::params::database_user,
  $password                      = $zabbix::params::database_password,
  $port                          = $zabbix::params::database_port,
  $listenport                    = $zabbix::params::frontend_ListenPort,
  $listenip                      = $zabbix::params::frontend_ListenIP,
  $timezone                      = $zabbix::params::frontend_Timezone,
  $max_execution_time            = $zabbix::params::apache_php_max_execution_time,
  $memory_limit                  = $zabbix::params::apache_php_memory_limit,
  $post_max_size                 = $zabbix::params::apache_php_post_max_size,
  $upload_max_filesize           = $zabbix::params::apache_php_upload_max_filesize,
  $max_input_time                = $zabbix::params::apache_php_max_input_time,
  $always_populate_raw_post_data = $zabbix::params::apache_php_always_populate_raw_post_data,
) inherits zabbix::params {
  
  if $zabbix_repo {
    class { 'zabbix::repo':
      zabbix_version => $zabbix_version,
    }
    Class['zabbix::repo'] -> Package['zabbix-frontend-php']
  }

  case $::operatingsystem {
    
    'debian', 'ubuntu' : {
      if $zabbix_repo {
        class { 'zabbix::repo':
          zabbix_version => $zabbix_version,
        }
        Class['zabbix::repo'] -> Package['zabbix-frontend-php']
      }
      package { 'zabbix-frontend-php':
        ensure  => 'present',
      }
      
      file { '/etc/zabbix/zabbix.conf.php':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        replace => true,
        content => template('zabbix.conf.php.erb'),
      }

      Service['apache'] -> Package['zabbix-frontend-php']
      
      Class['apache::vhost'] -> File['/etc/zabbix/zabbix.conf.php'] -> Package['zabbix-frontend-php']
    }
    
    'centos','scientific','redhat','oraclelinux' : {
      if $zabbix_repo {
        class { 'zabbix::repo':
          zabbix_version => $zabbix_version,
        }
        Class['zabbix::repo'] -> Package['zabbix-web-${type}']
      }
      package { 'zabbix-web-${type}':
        ensure  => 'present',
      }
      
      file { '/etc/zabbix/web/zabbix.conf.php':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        replace => true,
        content => template('zabbix.conf.php.erb'),
      }
      
      Service['apache'] -> Package['zabbix-web-${type}']
      
      Class['apache::vhost'] -> File['/etc/zabbix/web/zabbix.conf.php'] -> Package['zabbix-frontend-${type}']
    }
    
  }

    class { 'apache': }

    if versioncmp($::apache::apache_version, '2.4') >= 0 {
      $directory_allow = { 'require' => 'all granted', }
      $directory_deny = { 'require' => 'all denied', }
    } else {
      $directory_allow = { 'allow' => 'from all', 'order' => 'Allow,Deny', }
      $directory_deny = { 'deny' => 'from all', 'order' => 'Deny,Allow', }
    }

    apache::vhost { $url:
      docroot         => '/usr/share/zabbix',
      ip              => $listenip,
      port            => $listenport,
      add_listen      => true,
      directories     => [
        merge({
          path     => '/usr/share/zabbix',
          provider => 'directory',
        }, $directory_allow),
        merge({
          path     => '/usr/share/zabbix/conf',
          provider => 'directory',
        }, $directory_deny),
        merge({
          path     => '/usr/share/zabbix/api',
          provider => 'directory',
        }, $directory_deny),
        merge({
          path     => '/usr/share/zabbix/include',
          provider => 'directory',
        }, $directory_deny),
        merge({
          path     => '/usr/share/zabbix/include/classes',
          provider => 'directory',
        }, $directory_deny),
      ],
      custom_fragment => "
   php_value max_execution_time ${max_execution_time}
   php_value memory_limit ${memory_limit}
   php_value post_max_size ${post_max_size}
   php_value upload_max_filesize ${upload_max_filesize}
   php_value max_input_time ${max_input_time}
   php_value always_populate_raw_post_data ${always_populate_raw_post_data}
   # Set correct timezone
   php_value date.timezone ${timezone}",
      rewrites        => [
        {
          rewrite_rule => ['^$ /index.php [L]'] }
      ],
#      require         => File['/etc/zabbix/web/zabbix.conf.php'],
    }
  
  service { 'apache':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}