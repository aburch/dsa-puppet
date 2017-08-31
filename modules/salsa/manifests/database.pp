#
class salsa::database inherits salsa {
	include postgresql::server
	ensure_packages ( "postgresql-contrib-9.6", { ensure => 'installed' })

	postgresql::server::db { $salsa::db_name:
		user     => $salsa::db_role,
		password => postgresql_password($salsa::db_role, $salsa::db_password),
	}

	postgresql::server::extension { 'pg_trgm':
		database => $salsa::db_name,
		require => Package['postgresql-contrib-9.6'],
	}

	# XXX set up backups
	file { "/var/lib/postgresql/9.6/main/.nobackup":
		content  => ""
	}
}
