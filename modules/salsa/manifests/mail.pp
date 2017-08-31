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

	$pw_salt = hkdf('/etc/puppet/secret', "mail-imap-dovecot-${::hostname}-${salsa::servicename}-${salsa::mail_username}-salt-generator")
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
				disable_plaintext_auth = no

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
	file { '/etc/dovecot/local.conf':
		content  => @(EOF),
				mail_location = maildir:~/Maildir

				service imap-login {
				  inet_listener imap {
					address = 127.0.0.1
				  }
				}

				service lmtp {
				  unix_listener /var/spool/postfix/private/dovecot-lmtp {
				    group = postfix
				    user = postfix
				    mode = 0660
				  }
				  client_limit = 1
				}

				| EOF
		notify => Service['dovecot'],
	}

	concat::fragment { 'puppet-postfix-main.cf--salsa':
		target => '/etc/postfix/main.cf',
		order  => '020',
		content => @("EOF"),
				recipient_delimiter = +

				mydestination =
				virtual_transport = lmtp:unix:private/dovecot-lmtp
				virtual_mailbox_domains = ${salsa::servicename}
				virtual_alias_maps = hash:/etc/postfix/virtual

				| EOF
	}
	exec { '/usr/sbin/postmap /etc/postfix/virtual':
		refreshonly => true,
		require =>  Package['postfix'],
	}
	file { '/etc/postfix/virtual':
		content  => @("EOF"),
				postmaster@${salsa::servicename} postmaster@debian.org
				admin@${salsa::servicename}      salsa-admin@debian.org
				| EOF
		notify => Exec['/usr/sbin/postmap /etc/postfix/virtual'],
	}

}
