class bacula::storage inherits bacula {

	package { 'bacula-sd':
		ensure => installed
	}

	service { 'bacula-sd':
		ensure    => running,
		enable    => true,
		hasstatus => true,
	}
	systemd::override { 'bacula-sd':
		content => @(EOT)
			[Service]
			Group=bacula
			SupplementaryGroups=ssl-cert
			| EOT
	}

	exec { 'bacula-sd restart-when-idle':
		path        => '/usr/bin:/usr/sbin:/bin:/sbin',
		command     => 'sh -c "setsid /usr/local/sbin/bacula-idle-restart sd &"',
		refreshonly => true,
		subscribe   => File[$bacula_ssl_server_cert],
		require     => File['/usr/local/sbin/bacula-idle-restart'],
	}


	file { '/etc/bacula/bacula-sd.conf':
		content => template('bacula/bacula-sd.conf.erb'),
		mode    => '0640',
		group   => bacula,
		notify  => Exec['bacula-sd restart-when-idle']
	}

	file { '/etc/bacula/storage-conf.d':
		ensure  => directory,
		mode    => '0755',
		group   => bacula,
		purge   => true,
		force   => true,
		recurse => true,
		source  => 'puppet:///files/empty/',
		notify  => Exec['bacula-sd restart-when-idle']
	}

	@ferm::rule { 'dsa-bacula-sd-v4':
		domain      => '(ip)',
		description => 'Allow bacula-sd access from director and clients',
		rule        => 'proto tcp mod state state (NEW) dport (bacula-sd) @subchain \'bacula-sd\' { saddr ($HOST_DEBIAN_V4 5.153.231.125 5.153.231.126) ACCEPT; }',
		notarule    => true,
	}

	@ferm::rule { 'dsa-bacula-sd-v6':
		domain      => '(ip6)',
		description => 'Allow bacula-sd access from director and clients',
		rule        => 'proto tcp mod state state (NEW) dport (bacula-sd) @subchain \'bacula-sd\' { saddr ($HOST_DEBIAN_V6) ACCEPT; }',
		notarule    => true,
	}

	file { '/etc/bacula/storage-conf.d/empty.conf':
		content => '',
		mode    => '0440',
		group   => bacula,
		notify  => Exec['bacula-sd restart-when-idle']
	}

	file { "${bacula_backup_path}/Catalog":
		ensure  => directory,
		mode    => '0755',
		owner   => bacula,
		group   => bacula,
		;
	}

	package { 'python3-psycopg2': ensure => installed }
	file { '/usr/local/bin/bacula-unlink-removed-volumes':
		source  => 'puppet:///modules/bacula/bacula-unlink-removed-volumes',
		mode    => '0555',
	}
	file { "/etc/cron.d/puppet-bacula-storage-stuff":
		content => "MAILTO=root\n@daily bacula chronic /usr/local/bin/bacula-unlink-removed-volumes -v\n";
	}

	Bacula::Storage_per_node<<| |>>
}
