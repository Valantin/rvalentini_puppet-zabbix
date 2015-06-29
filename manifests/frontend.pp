class zabbix::frontend (
  $zabbix_version                = $zabbix::params::zabbix_version,
  $zabbix_repo                   = $zabbix::params::zabbix_repo,
  $zabbix_server                 = $zabbix::params::zabbix_server,
  $zabbix_server_name            = $zabbix::params::zabbix_server_name,
  $zabbix_listenport             = $zabbix::params::server_ListenPort,
  $url                           = $zabbix::params::frontend_url,
  $dbtype                        = $zabbix::params::zabbix_database,
  $dbhost                        = $zabbix::params::database_host,
  $dbname                        = $zabbix::params::database_name,
  $dbschema                      = $zabbix::params::database_schema,
  $dbuser                        = $zabbix::params::database_user,
  $dbpassword                    = $zabbix::params::database_password,
  $dbport                        = $zabbix::params::database_port,
  $listenport                    = $zabbix::params::frontend_ListenPort,
  $listenip                      = $zabbix::params::frontend_ListenIP,
  $date_timezone                 = $zabbix::params::frontend_Timezone,
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
        
      }

  case $::operatingsystem {
    
    'debian','ubuntu' : {
      package { 'zabbix-frontend-php':
        ensure  => 'present',
      }
      if $zabbix_repo {
        Class['zabbix::repo'] -> Package['zabbix-frontend-php']
      }
      file { '/etc/zabbix/zabbix.conf.php':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        replace => true,
        content => template('zabbix/zabbix.conf.php.erb'),
      }
      
      Service['apache'] -> Class['apache'] -> File['/etc/zabbix/zabbix.conf.php'] -> Package['zabbix-frontend-php']
    }
    
    'centos','scientific','redhat','oraclelinux' : {
      if $zabbix_repo {
        Class['zabbix::repo'] -> Package["zabbix-web-${dbtype}"]
      }
      package { "zabbix-web-${dbtype}":
        ensure  => 'present',
      }
      
      file { '/etc/zabbix/web/zabbix.conf.php':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        replace => true,
        content => template('zabbix/zabbix.conf.php.erb'),
      }
      
      Service['apache'] -> Class['apache'] -> File['/etc/zabbix/web/zabbix.conf.php'] -> Package["zabbix-web-${type}"]
    }
    
  }

  class { 'apache': }

  apache::custom_config { 'zabix':
    content => "<IfModule mod_alias.c>
    Alias /zabbix /usr/share/zabbix
</IfModule>

<Directory \"/usr/share/zabbix\">
    Options FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all

    php_value max_execution_time 300
    php_value memory_limit 128M
    php_value post_max_size 16M
    php_value upload_max_filesize 2M
    php_value max_input_time 300
    php_value date.timezone Europe/Rome
</Directory>

<Directory \"/usr/share/zabbix/conf\">
    Order deny,allow
    Deny from all
    <files *.php>
        Order deny,allow
        Deny from all
    </files>
</Directory>

<Directory \"/usr/share/zabbix/api\">
    Order deny,allow
    Deny from all
    <files *.php>
        Order deny,allow
        Deny from all
    </files>
</Directory>

<Directory \"/usr/share/zabbix/include\">
    Order deny,allow
    Deny from all
    <files *.php>
        Order deny,allow
        Deny from all
    </files>
</Directory>

<Directory \"/usr/share/zabbix/include/classes\">
    Order deny,allow
    Deny from all
    <files *.php>
        Order deny,allow
        Deny from all
    </files>
</Directory>",
  }

  service { 'apache':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}