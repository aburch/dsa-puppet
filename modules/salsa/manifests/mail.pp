#
class salsa::mail inherits salsa {
	package { [
		'dovecot-imapd',
		'dovecot-lmtpd',
		]:
		ensure => installed
	}
	service { 'dovecot':
		ensure => running,
	}

	group { '_vmail':
		system => true,
		ensure => 'present',
	}
	user { '_vmail':
		system => true,
		gid    => '_vmail',
		ensure => 'present',
		home   => '/srv/mail',
		shell  => '/bin/false',
	}

	file { '/srv/mail':
		ensure => 'directory',
		mode => '0700',
		owner => '_vmail',
		group => '_vmail',
	}

	file { '/etc/dovecot/users':
		# XXX fix uid/git/password
		mode => '440',
		group => 'dovecot',
		content  => @(EOF),
				gitlab:$6$PoaX25m/P52bFbEU$tguOOYZZvOD49cmtlrqgRL4nKluakaVudPYOKkEcDZu/fZXXxyqjga9HypFwmBrj3uSP/wt2rqq7BNy22MlU90:::
				| EOF
	}


	file { '/etc/dovecot/conf.d/10-auth.conf':
		content  => @(EOF),
				auth_mechanisms = plain

				passdb {
				  driver = passwd-file
				  args = scheme=CRYPT username_format=%u /etc/dovecot/users
				}

				userdb {
				  driver = passwd-file
				  args = username_format=%u /etc/dovecot/users
				  default_fields = uid=_vmail gid=_vmail home=/srv/mail/%u
				}
				| EOF
		notify => Service['dovecot'],
	}
}
