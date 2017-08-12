class named::geodns inherits named {
	munin::check { 'bind_views':
		script => bind
	}

	package { 'geoip-database':
		ensure => installed,
	}

	#site::aptrepo { 'geoip':
	#	url        => 'http://db.debian.org/debian-admin',
	#	suite      => 'lenny-bind-geoip',
	#	components => 'main',
	#}
	site::aptrepo { 'geoip': ensure => absent }

	file { '/etc/bind/':
		ensure  => directory,
		group  => bind,
		mode   => '2755',
		require => Package['bind9'],
		notify  => Service['bind9'],
	}
	file { '/etc/bind/geodns':
		ensure => directory,
		mode   => '0755',
	}
	file { '/etc/bind/named.conf.options':
		content => template('named/named.conf.options.erb'),
		notify  => Service['bind9'],
	}
	file { '/etc/bind/named.conf.local':
		source => 'puppet:///modules/named/common/named.conf.local',
		notify  => Service['bind9'],
	}
        if (versioncmp($::lsbmajdistrelease, '9') >= 0) {
		file { '/etc/bind/named.conf.acl':
			source => 'puppet:///modules/named/common/named.conf.acl',
			notify  => Service['bind9'],
		}
	} else {
		file { '/etc/bind/named.conf.acl':
			source => 'puppet:///modules/named/common/named.conf.acl.bind99',
			notify  => Service['bind9'],
		}
	}
	file { '/etc/bind/geodns/zonefiles':
		ensure => directory,
		owner  => geodnssync,
		group  => geodnssync,
		mode   => '2755',
	}
	file { '/etc/bind/geodns/named.conf.geo':
		source => 'puppet:///modules/named/common/named.conf.geo',
		notify  => Service['bind9'],
	}
	file { '/etc/bind/geodns/trigger':
		mode   => '0555',
		source => 'puppet:///modules/named/common/trigger',
	}
	file { '/etc/ssh/userkeys/geodnssync':
		source => 'puppet:///modules/named/common/authorized_keys',
		group  => geodnssync,
		mode   => '0440',
	}
	file { '/etc/cron.d/dsa-boot-geodnssync':
		source => 'puppet:///modules/named/common/cron-geo'
	}
}
