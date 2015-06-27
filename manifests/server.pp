class zabbix::server (
  $zabbix_version          = $zabbix::params::zabbix_version,
  $zabbix_repo             = $zabbix::params::zabbix_repo,
  $db                      = $zabbix::params::zabbix_database,
  $configfile              = $zabbix::params::server_config_file,
  $server_config_group     = $zabbix::params::server_config_group,
  $server_service_name     = $zabbix::params::server_service_name,
  $nodeid                  = $zabbix::params::server_NodeID,
  $listenport              = $zabbix::params::server_ListenPort,
  $sourceip                = $zabbix::params::server_SourceIP,
  $logfile                 = $zabbix::params::server_LogFile,
  $logfilesize             = $zabbix::params::server_LogFileSize,
  $debuglevel              = $zabbix::params::server_DebugLevel,
  $pidfile                 = $zabbix::params::server_PidFile,
  $dbhost                  = $zabbix::params::server_DBHost,
  $dbname                  = $zabbix::params::server_DBName,
  $dbschema                = $zabbix::params::server_DBSchema,
  $dbuser                  = $zabbix::params::server_DBUser,
  $dbpassword              = $zabbix::params::server_DBPassword,
  $dbsocket                = $zabbix::params::server_DBSocket,
  $dbport                  = $zabbix::params::server_DBPort,
  $startpollers            = $zabbix::params::server_StartPollers,
  $startipmipollers        = $zabbix::params::server_StartIPMIPollers,
  $startpollersunreachable = $zabbix::params::server_StartPollersUnreachable,
  $starttrappers           = $zabbix::params::server_StartTrappers,
  $startpingers            = $zabbix::params::server_StartPingers,
  $startdiscoverers        = $zabbix::params::server_StartDiscoverers,
  $starthttppollers        = $zabbix::params::server_StartHTTPPollers,
  $javagateway             = $zabbix::params::server_JavaGateway,
  $javagatewayport         = $zabbix::params::server_JavaGatewayPort,
  $startjavapollers        = $zabbix::params::server_StartJavaPollers,
  $snmptrapperfile         = $zabbix::params::server_SNMPTrapperFile,
  $startsnmptrapper        = $zabbix::params::server_StartSNMPTrapper,
  $listenip                = $zabbix::params::server_ListenIP,
  $housekeepingfrequency   = $zabbix::params::server_HousekeepingFrequency,
  $maxhousekeeperdelete    = $zabbix::params::server_MaxHousekeeperDelete,
  $senderfrequency         = $zabbix::params::server_SenderFrequency,
  $cachesize               = $zabbix::params::server_CacheSize,
  $cacheupdatefrequency    = $zabbix::params::server_CacheUpdateFrequency,
  $startdbsyncers          = $zabbix::params::server_StartDBSyncers,
  $historycachesize        = $zabbix::params::server_HistoryCacheSize,
  $trendcachesize          = $zabbix::params::server_TrendCacheSize,
  $historytextcachesize    = $zabbix::params::server_HistoryTextCacheSize,
  $nodenoevents            = $zabbix::params::server_NodeNoEvents,
  $nodenohistory           = $zabbix::params::server_NodeNoHistory,
  $timeout                 = $zabbix::params::server_Timeout,
  $trappertimeout          = $zabbix::params::server_TrapperTimeout,
  $unreachableperiod       = $zabbix::params::server_UnreachablePeriod,
  $unavailabledelay        = $zabbix::params::server_UnavailableDelay,
  $unreachabledelay        = $zabbix::params::server_UnreachableDelay,
  $alertscriptspath        = $zabbix::params::server_AlertScriptsPath,
  $externalscripts         = $zabbix::params::server_ExternalScripts,
  $fpinglocation           = $zabbix::params::server_FpingLocation,
  $fping6location          = $zabbix::params::server_Fping6Location,
  $sshkeylocation          = $zabbix::params::server_SSHKeyLocation,
  $logslowqueries          = $zabbix::params::server_LogSlowQueries,
  $tmpdir                  = $zabbix::params::server_TmpDir,
  $startproxypollers       = $zabbix::params::server_StartProxyPollers,
  $proxyconfigfrequency    = $zabbix::params::server_ProxyConfigFrequency,
  $proxydatafrequency      = $zabbix::params::server_ProxyDataFrequency,
  $include_dir             = $zabbix::params::server_Include,
) inherits zabbix::params {
  if $zabbix_repo {
    class { 'zabbix::repo':
      zabbix_version => $zabbix_version,
    }
    Class['zabbix::repo'] -> Package['zabbix-server-${db}']
  }
  
  package { 'zabbix-server-${db}':
    ensure  => 'present',
  }
  
  service { 'zabbix-server':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  Service['zabbix-server'] -> Package['zabbix-server-${db}']
  
  file { $configfile:
    ensure  => present,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0644',
    replace => true,
    content => template('zabbix/zabbix_server.conf.erb'),
  }

  Service['zabbix-server'] ~> File[$configfile]
}