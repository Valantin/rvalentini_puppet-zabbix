class zabbix::agent (
  $zabbix_version        = $zabbix::params::zabbix_version,
  $zabbix_repo           = $zabbix::params::zabbix_repo,
  $configfile            = $zabbix::params::agent_config_file,
  $pidfile               = $zabbix::params::agent_PidFile,
  $logfile               = $zabbix::params::agent_LogFile,
  $logfilesize           = $zabbix::params::agent_LogFileSize,
  $debuglevel            = $zabbix::params::agent_DebugLevel,
  $sourceip              = $zabbix::params::agent_SourceIP,
  $enableremotecommands  = $zabbix::params::agent_EnableRemoteCommands,
  $logremotecommands     = $zabbix::params::agent_LogRemoteCommands,
  $server                = $zabbix::params::agent_Server,
  $listenport            = $zabbix::params::agent_ListenPort,
  $listenip              = $zabbix::params::agent_ListenIP,
  $startagents           = $zabbix::params::agent_StartAgents,
  $serveractive          = $zabbix::params::agent_ServerActive,
  $hostname              = $zabbix::params::agent_Hostname,
  $hostnameitem          = $zabbix::params::agent_HostnameItem,
  $hostmetadata          = $zabbix::params::agent_HostMetadata,
  $hostmetadataitem      = $zabbix::params::agent_HostMetadataItem,
  $refreshactivechecks   = $zabbix::params::agent_RefreshActiveChecks,
  $buffersend            = $zabbix::params::agent_BufferSend,
  $buffersize            = $zabbix::params::agent_BufferSize,
  $maxlinespersecond     = $zabbix::params::agent_MaxLinesPerSecond,
  $allowroot             = $zabbix::params::agent_AllowRoot,
  $alias                 = $zabbix::params::agent_Alias,
  $timeout               = $zabbix::params::agent_Timeout,
  $include_dir           = $zabbix::params::agent_Include,
  $unsafeuserparameters  = $zabbix::params::agent_UnsafeUserParameters,
  $userparameter         = $zabbix::params::agent_UserParameter,
  $loadmodulepath        = $zabbix::params::agent_LoadModulePath,
  $loadmodule            = $zabbix::params::agent_LoadModule,
  ) inherits zabbix::params {

  # Check if manage_repo is true.
  if $zabbix_repo {
    include zabbix::repo
    Class['zabbix::repo'] -> Package['zabbix-agent']
  }

  # Installing the package
  package { 'zabbix-agent':
    ensure  => 'present',
  }

  # Controlling the 'zabbix-agent' service
  service { 'zabbix-agent':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  Service['zabbix-agent'] -> Package['zabbix-agent']

  # Configuring the zabbix-agent configuration file
  file { $configfile:
    ensure  => present,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0644',
    replace => true,
    content => template('zabbix/zabbix_agentd.conf.erb'),
  }

  Service['zabbix-agent'] ~> File[$configfile]

  if $include_dir {
    # Include dir for specific zabbix-agent checks.
    file { $include_dir:
      ensure  => directory,
      owner   => 'zabbix',
      group   => 'zabbix',
      recurse => true,
    }
  
    Service['zabbix-agent'] ~> File[$include_dir]
    Package['zabbix-agent'] -> File[$configfile] -> File[$include_dir]
  }
}