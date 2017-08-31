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

	$pw_salt = hkdf('/etc/puppet/secret', "mail-imap-dovecot-${::hostname}-salsa-${mail_username}-salt-generator")
	$hashed_pw = pw_hash($salsa::mail_password, 'SHA-512', $pw_salt)
	file { '/etc/dovecot/users':
		mode => '440',
		group => 'dovecot',
		content  => @("EOF"),
				${salsa::mail_username}:${hashed_pw}:::
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
