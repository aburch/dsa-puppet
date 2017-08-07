class puppetmaster {

	package { 'puppetmaster':
		ensure => installed,
	}
	file { '/etc/puppet/hiera.yaml':
		source => 'puppet:///modules/puppetmaster/hiera.yaml'
	}
	file { '/etc/puppet/puppetdb.conf':
		source => 'puppet:///modules/puppetmaster/puppetdb.conf'
	}

	@ferm::rule { 'dsa-puppet':
		description     => 'Allow puppet access',
		rule            => '&SERVICE_RANGE(tcp, 8140, $HOST_DEBIAN_V4)'
	}
	@ferm::rule { 'dsa-puppet-v6':
		domain          => 'ip6',
		description     => 'Allow puppet access',
		rule            => '&SERVICE_RANGE(tcp, 8140, $HOST_DEBIAN_V6)'
	}

	file { '/srv/puppet.debian.org/puppet-facts':
		ensure => directory
	}
	concat { '/srv/puppet.debian.org/puppet-facts/onionbalance-services.yaml':
	}
	Concat::Fragment <<| tag == "onionbalance-services.yaml" |>>

	file { '/etc/cron.d/puppet-update-fastly-ips':
		source => 'puppet:///modules/puppetmaster/update-fastly-ips.cron'
	}
	file { '/etc/cron.d/update-fastly-ips':
		ensure => absent,
	}
	file { '/usr/local/bin/update-fastly-ips':
		source => 'puppet:///modules/puppetmaster/update-fastly-ips.sh',
		mode   => '0555',
	}
}
