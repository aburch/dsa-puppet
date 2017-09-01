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

	$db_backup_role = 'debian-backup'
	$db_backup_role_password = hkdf('/etc/puppet/secret', "postgresql-${::hostname}-${postgresql::params::port}-backup_role}")

	# XXX - get these from the roles and ldap
	$db_backup_hosts = ['5.153.231.12/32', '93.94.130.161/32', '2001:41c8:1000:21::21:12/128', '2a02:158:380:280::161/128']

	postgresql::server::role { $db_backup_role:
		password_hash => postgresql_password($db_backup_role, $db_backup_role_password),
		replication => true,
	}
	$db_backup_hosts.each |String $address| {
		postgresql::server::pg_hba_rule { "debian_backup-${address}":
			description => 'Open up PostgreSQL for backups',
			type        => 'hostssl',
			database    => 'replication',
			user        => $db_backup_role,
			address     => $address,
			auth_method => 'md5',
		}
	}
	@ferm::rule { "dsa-postgres-${postgresql::params::port}":
		description => 'Allow postgress access from backup host',
		domain      => '(ip ip6)',
		rule        => "&SERVICE_RANGE(tcp, ${postgresql::params::port}, ( @ipfilter(\$HOST_PGBACKUPHOST) ))",
	}

	# add cluster to make-base-backups
}
