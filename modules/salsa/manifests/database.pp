#
class salsa::database inherits salsa {
# XXX does not work just yet.

#	include postgresql::server
#
#	postgresql::server::db { $salsa::db_name:
#		user     => $salsa::db_role,
#		password => postgresql_password($salsa::db_role, $salsa::db_password),
#	}
#
#	postgresql::server::extension { 'pg_trgm':
#		database => $salsa::db_name,
#	}

# so do things by hand for now
	ensure_packages ( "postgresql", { ensure => 'installed' })
	# create role, create db owned by role, add extension

	# XXX set up backups
	file { "/var/lib/postgresql/9.6/main/.nobackup":
		content  => ""
	}
}
