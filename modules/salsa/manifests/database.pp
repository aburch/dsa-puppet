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

	$datadir = assert_type(String[1], $postgresql::params::datadir)
	file { "${datadir}/.nobackup":
		content  => ""
	}
}
