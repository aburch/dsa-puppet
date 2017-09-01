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
	$datadir = assert_type(String[1], $postgresql::params::datadir)
	warning("foo ")
	file { "${datadir}/.nobackup":
		content  => ""
	}
	if $::postgresql_key {
		$ipaddr = assert_type(String[1], join(getfromhash($site::nodeinfo, 'ldap', 'ipHostNumber'), ","))

		@@concat::fragment { "onion::balance::instance::dsa-snippet::$name::$fqdn":
			target  => "/etc/dsa/postgresql-backup/sshkeys-sources",
			content  => @("EOF"),
					${::hostname} ${ipaddr} ${::postgresql_key}
					| EOF
			tag     => "postgresql::server::backup-source-sshkey",
		}
	}
}
