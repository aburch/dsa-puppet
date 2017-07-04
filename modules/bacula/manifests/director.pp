class bacula::director inherits bacula {

	package { ['bacula-director-pgsql', 'bacula-common', 'bacula-common-pgsql']:
		ensure => installed
	}

	service { 'bacula-director':
		ensure    => running,
		enable    => true,
		hasstatus => true,
		require   => Package['bacula-director-pgsql']
	}

	exec { 'bacula-director reload':
		path        => '/usr/bin:/usr/sbin:/bin:/sbin',
		command     => 'service bacula-director reload',
		refreshonly => true,
	}

	file { '/etc/bacula/conf.d':
		ensure  => directory,
		mode    => '0755',
		group   => bacula,
		purge   => true,
		force   => true,
		recurse => true,
		source  => 'puppet:///files/empty/',
		notify  => Exec['bacula-director reload']
	}

	file { '/etc/bacula/bacula-dir.conf':
		content => template('bacula/bacula-dir.conf.erb'),
		mode    => '0440',
		group   => bacula,
		require => Package['bacula-director-pgsql'],
		notify  => Exec['bacula-director reload']
	}

	@ferm::rule { 'dsa-bacula-dir':
		domain      => '(ip)',
		description => 'Allow bacula access from localhost',
		rule        => "proto tcp mod state state (NEW) dport (bacula-dir) saddr (${bacula_director_ip} localhost) ACCEPT",
	}

	file { '/etc/bacula/conf.d/empty.conf':
		content => '',
		mode    => '0440',
		group   => bacula,
		require => Package['bacula-director-pgsql'],
		notify  => Exec['bacula-director reload']
	}

	Bacula::Node<<| |>>

	package { 'bacula-console':
		ensure => installed;
	}

	file { '/etc/bacula/bconsole.conf':
		content => template('bacula/bconsole.conf.erb'),
		mode    => '0640',
		group   => bacula,
		require => Package['bacula-console']
	}

	package { 'python3-psycopg2': ensure => installed }
	file { '/etc/bacula/scripts/volume-purge-action':
		mode    => '0555',
		source  => 'puppet:///modules/bacula/volume-purge-action',
		;
	}
	file { '/etc/bacula/scripts/volumes-delete-old':
		mode    => '0555',
		source  => 'puppet:///modules/bacula/volumes-delete-old',
		;
	}
	file { '/etc/bacula/storages-list.d':
		ensure  => directory,
		mode    => '0755',
		group   => bacula,
		purge   => true,
		force   => true,
		recurse => true,
		source  => 'puppet:///files/empty/',
	}
	file { "/etc/cron.d/puppet-bacula-stuff":
		source  => 'puppet:///modules/bacula/crontab-director',
	}
}
