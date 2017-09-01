#
class postgres::backup_server::globals {
	$make_base_backups = '/usr/local/bin/postgres-make-base-backups'
	$pgpassfile = '/home/debbackup/.pgpass'
	$sshkeys_sources = '/etc/dsa/postgresql-backup/sshkeys-sources'

	$tag_base_backup = "postgresql::server::backup-source-make-base-backup-entry"
	$tag_source_sshkey = "postgresql::server::backup-source-sshkey"
	$tag_source_pgpassline = "postgresql::server::backup-source-pgpassline"
}

class postgres::backup_server {
	include postgres::backup_server::globals

	package { 'postgresql-client-9.1':
		ensure => installed
	}
	package { 'postgresql-client-9.4':
		ensure => installed
	}

	concat { $postgres::backup_server::globals::make_base_backups:
		mode => '0555',
	}
	concat::fragment { 'make-base-backups-header':
		target => $postgres::backup_server::globals::make_base_backups,
		content => template('postgres/backup_server/postgres-make-base-backups.erb'),
		order  => '00',
	}
	Concat::Fragment <<| tag == $postgres::backup_server::globals::tag_base_backup |>>
	concat::fragment { 'make-base-backups-tail':
		target => $postgres::backup_server::globals::make_base_backups,
		content  => @(EOTEMPLATE),
				# EOF by make-base-backups-tail fragment
				EOF
				| EOTEMPLATE
		order  => '99',
	}
	if $::hostname in [backuphost] {
		file { '/etc/cron.d/puppet-postgres-make-base-backups':
			content  => "20 1 * * 0 debbackup chronic ${$postgres::backup_server::globals::make_base_backups}\n",
		}
	} else  {
		file { '/etc/cron.d/puppet-postgres-make-base-backups':
			content  => "20 0 * * 6 debbackup chronic ${$postgres::backup_server::globals::make_base_backups}\n",
		}
	}

	# Maintain authorized_keys file on backup servers for WAL shipping
	#
	# do not let other hosts directly build our authorized_keys file,
	# instead go via a script that somewhat validates intput
	file { '/etc/dsa/postgresql-backup':
		ensure => 'directory',
	}
	file { '/usr/local/bin/postgres-make-backup-sshauthkeys':
		content => template('postgres/backup_server/postgres-make-backup-sshauthkeys.erb'),
		mode   => '0555',
		notify  => Exec['postgres-make-backup-sshauthkeys'],
	}
	file { '/etc/dsa/postgresql-backup/sshkeys-manual':
		content => template('postgres/backup_server/sshkeys-manual.erb'),
		notify  => Exec['postgres-make-backup-sshauthkeys'],
	}
	concat { $postgres::backup_server::globals::sshkeys_sources:
		notify  => Exec['postgres-make-backup-sshauthkeys'],
	}
	concat::fragment { 'postgresql-backup/source-sshkeys-header':
		target => $postgres::backup_server::globals::sshkeys_sources ,
		content  => @(EOF),
				# <name> <ip addresses> <key>
				| EOF
		order  => '00',
	}
	Concat::Fragment <<| tag == $postgres::backup_server::globals::tag_source_sshkey |>>
	exec { "postgres-make-backup-sshauthkeys":
		command => "/usr/local/bin/postgres-make-backup-sshauthkeys",
		refreshonly => true,
	}

	# Maintain .pgpass file on backup servers
	concat { $postgres::backup_server::globals::pgpassfile:
		owner => 'debbackup',
		group => 'debbackup',
		mode  => '0400'
	}
	concat::fragment{ 'pgpass-local':
		target => $postgres::backup_server::globals::pgpassfile,
		source => '/home/debbackup/.pgpass-local',
		order  => '00'
	}
	Concat::Fragment <<| tag == $postgres::backup_server::globals::tag_source_pgpassline |>>
}

define postgres::backup_server::register_backup_clienthost (
	$sshpubkey = $::postgresql_key,
	$ipaddrlist = join(getfromhash($site::nodeinfo, 'ldap', 'ipHostNumber'), ","),
	$hostname = $::hostname,
) {
	include postgres::backup_server::globals

	if $sshpubkey {
		$addr = assert_type(String[1], $ipaddrlist)
		@@concat::fragment { "postgresql::server::backup-source-clienthost::$name::$fqdn":
			target => $postgres::backup_server::globals::sshkeys_sources ,
			content  => @("EOF"),
					${hostname} ${addr} ${sshpubkey}
					| EOF
			tag     => $postgres::backup_server::globals::tag_source_sshkey,
		}
	}
}

define postgres::backup_server::register_backup_cluster (
	$hostname = $::fqdn,
	$pg_port,
	$pg_role,
	$pg_password,
	$pg_cluster,
	$pg_version,
) {
	include postgres::backup_server::globals

	# foobar.debian.org:5432:*:debian-backup:swordfish
	@@concat::fragment { "postgresql::server::backup-source-pgpassline::$hostname::$pg_port::$pg_role":
		target => $postgres::backup_server::globals::pgpassfile,
		content => @("EOF"),
				${hostname}:${pg_port}:*:${pg_role}:${pg_password}
				| EOF
		tag     => $postgres::backup_server::globals::tag_source_pgpassline,
	}
	#
	# vittoria.debian.org	5432	debian-backup		main		9.6
	@@concat::fragment { "postgresql::server::backup-source-make-base-backup-entry::$hostname::$pg_port::$pg_role":
		target => $postgres::backup_server::globals::make_base_backups,
		content => @("EOF"),
				${hostname}	${pg_port}	${pg_role}	${pg_cluster}	${pg_version}
				| EOF
		tag     => $postgres::backup_server::globals::tag_base_backup,
	}
}
