#
class salsa::database inherits salsa {
	class { 'postgresql::globals':
		version => '9.6',
	}
	class { 'postgresql::server':
		listen_addresses => '*',
	}
	class { 'postgresql::server::contrib': }

	postgresql::server::db { $salsa::db_name:
		user     => $salsa::db_role,
		password => postgresql_password($salsa::db_role, $salsa::db_password),
	}

	postgresql::server::extension { 'pg_trgm':
		database => $salsa::db_name,
		require => Class['postgresql::server::contrib'],
	}



	include postgres::backup_source

	$pg_config_options = {
		'track_counts'  => 'yes',
		'archive_mode' => 'yes',
		'wal_level' => 'archive',
		'max_wal_senders' => '3',
		'archive_timeout' => '1h',
		'archive_command' => '/usr/local/bin/pg-backup-file main WAL %p',
		'ssl' => 'on',
		'ssl_cert_file' => '/etc/ssl/debian/certs/thishost-server.crt',
		'ssl_key_file' => '/etc/ssl/private/thishost-server.key',
	}
	$pg_config_options.each |String $key, String $value| {
		postgresql_conf { $key:
			value => $value,
			target => $postgresql::params::postgresql_conf_path,
			notify => Service['postgresqld'],
		}
	}

	postgres::backup_cluster { $::hostname:
		pg_version => $postgresql::params::version,
		pg_port => $postgresql::params::port,
		do_role => true,
		do_hba => true,
	}
}
