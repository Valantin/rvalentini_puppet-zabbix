class zabbix::repo(
  $zabbix_version = $zabbix::params::zabbix_version,
) inherits zabbix::params {
    class { 'apt': }

    case $::operatingsystemrelease {
      /^14.04/: {
        $dist_repo = 'trusty'
      }
      /^12.04/: {
        $dist_repo = 'precise'
      }
      /^10.04/: {
        $dist_repo = 'lucid'
      }
      /^8.*/: {
        $dist_repo = 'wheezy'
      }
      /^7.*/: {
        $majorrelease = '7'
        $dist_repo = 'wheezy'
      }
      /^6.*/: {
        $majorrelease = '6'
        $dist_repo = 'squeeze'
      }
      /^5.*/: {
        $majorrelease = '5'
        $dist_repo = 'lenny'
      }
      /\/sid$/: {
        $dist_repo = 'wheezy'
      }
      default: {
        fail("${::operatingsystem} ${::operatingsystemrelease}  was unsupported")
      }
    }

    case $::operatingsystem {
      'centos','scientific','redhat','oraclelinux' : {
        yumrepo { 'zabbix':
          name     => "Zabbix_${majorrelease}_${::architecture}",
          descr    => "Zabbix_${majorrelease}_${::architecture}",
          baseurl  => "http://repo.zabbix.com/zabbix/${zabbix_version}/rhel/${majorrelease}/${::architecture}/",
          gpgcheck => '1',
          gpgkey   => 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX',
          priority => '1',
        }
        yumrepo { 'zabbix-nonsupported':
          name     => "Zabbix_nonsupported_${majorrelease}_${::architecture}",
          descr    => "Zabbix_nonsupported_${majorrelease}_${::architecture}",
          baseurl  => "http://repo.zabbix.com/non-supported/rhel/${majorrelease}/${::architecture}/",
          gpgcheck => '1',
          gpgkey   => 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX',
          priority => '1',
        }

      }
      
      'debian','ubuntu' : {
        apt::source { 'zabbix':
          location   => "http://repo.zabbix.com/zabbix/${zabbix_version}/${::operatingsystem}/",
          release    => $dist_repo,
          repos      => 'main',
          key         => {
            'id'      => 'FBABD5FB20255ECAB22EE194D13D58E479EA5ED4',
            'source'  => 'http://repo.zabbix.com/zabbix-official-repo.key'
          },
        }
      }
      
      default : {
        fail('no repository found')
      }
    }
}