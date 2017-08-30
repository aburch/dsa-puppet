class postfix {
	package { 'postfix':
		ensure => installed
	}

	service { 'postfix':
		ensure => running
	}

	include debian_org::mail_incoming_port

	munin::check { 'ps_exim4':       ensure => absent }
	munin::check { 'exim_mailqueue': ensure => absent }
	munin::check { 'exim_mailstats': ensure => absent }

	munin::check { 'postfix_mailqueue': }
	munin::check { 'postfix_mailstats': }
	munin::check { 'postfix_mailvolume': }
	munin::check { 'ps_smtp': script => 'ps_' }
	munin::check { 'ps_smtpd': script => 'ps_' }

	if ! has_role('lists') {
		concat { '/etc/postfix/main.cf':
			notify  => Exec['service postfix reload'],
		}
		concat::fragment { 'puppet-postfix-main.cf--header':
			target => '/etc/postfix/main.cf',
			order  => '000',
			content => template('postfix/main.cf-header.erb')
		}
	}

	exec { 'service postfix reload':
		path        => '/usr/bin:/usr/sbin:/bin:/sbin',
		command     => 'service postfix reload',
		refreshonly => true,
		require =>  Package['postfix'],
	}
}
