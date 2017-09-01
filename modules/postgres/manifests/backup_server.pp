class postgres::backup_server {
	package { 'postgresql-client-9.1':
		ensure => installed
	}
	package { 'postgresql-client-9.4':
		ensure => installed
	}

	file { '/usr/local/bin/postgres-make-base-backups':
		content => template('postgres/backup_server/postgres-make-base-backups.erb'),
		mode   => '0555',
	}
	if $::hostname in [backuphost] {
		file { '/etc/cron.d/puppet-postgres-make-base-backups':
			content  => "20 1 * * 0 debbackup chronic /usr/local/bin/postgres-make-base-backups\n",
		}
	} else  {
		file { '/etc/cron.d/puppet-postgres-make-base-backups':
			content  => "20 0 * * 6 debbackup chronic /usr/local/bin/postgres-make-base-backups\n",
		}
	}

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
	concat { '/etc/dsa/postgresql-backup/sshkeys-sources':
		notify  => Exec['postgres-make-backup-sshauthkeys'],
	}
	concat::fragment { 'postgresql-backup/source-sshkeys-header':
		target => '/etc/dsa/postgresql-backup/sshkeys-sources',
		content  => @(EOF),
				# <name> <ip addresses> <key>
				| EOF
		order  => '00',
	}

	Concat::Fragment <<| tag == "postgresql::server::backup-source-sshkey" |>>

	exec { "postgres-make-backup-sshauthkeys":
		command => "/usr/local/bin/postgres-make-backup-sshauthkeys",
		refreshonly => true,
	}
}
