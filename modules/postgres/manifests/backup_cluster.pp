#
define postgres::backup_cluster(
	$pg_version,
	$pg_cluster = 'main',
	$pg_port = 5432,
	$backup_servers = getfromhash($site::roles, 'postgres_backup_server'),
	$db_backup_role = 'debian-backup',
	$db_backup_role_password = hkdf('/etc/puppet/secret', "postgresql-${::hostname}-${$pg_cluster}-${pg_port}-backup_role}"),
	$do_role = false,
	$do_hba = false,
) {
	$datadir = "/var/lib/postgresql/${pg_version}/${pg_cluster}"
	file { "${datadir}/.nobackup":
		content  => ""
	}

	## XXX - get these from the roles and ldap
	# backuphost, storace
	$backup_servers_addrs = ['5.153.231.12/32', '93.94.130.161/32', '2001:41c8:1000:21::21:12/128', '2a02:158:380:280::161/128']
	$backup_servers_addrs_joined = join($backup_servers_addrs, ' ')

	if $do_role {
		postgresql::server::role { $db_backup_role:
			password_hash => postgresql_password($db_backup_role, $db_backup_role_password),
			replication => true,
		}
	}
	if $do_hba {
		$backup_servers_addrs.each |String $address| {
			postgresql::server::pg_hba_rule { "debian_backup-${address}":
				description => 'Open up PostgreSQL for backups',
				type        => 'hostssl',
				database    => 'replication',
				user        => $db_backup_role,
				address     => $address,
				auth_method => 'md5',
			}
		}
	}
	@ferm::rule { "dsa-postgres-${pg_port}":
		description => 'Allow postgress access from backup host',
		domain      => '(ip ip6)',
		rule        => "&SERVICE_RANGE(tcp, ${pg_port}, ( @ipfilter((${backup_servers_addrs_joined})) ))",
	}

	postgres::backup_server::register_backup_cluster { "backup-role-${::fqdn}}-${pg_port}":
		pg_port => $pg_port,
		pg_role => $db_backup_role,
		pg_password => $db_backup_role_password,
		pg_cluster => $pg_cluster,
		pg_version => $pg_version,
	}
}
