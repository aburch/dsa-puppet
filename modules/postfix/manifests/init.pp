class postfix {
	package { 'postfix':
		ensure => installed
	}

	service { 'postfix':
		ensure => running
	}

	munin::check { 'ps_exim4':       ensure => absent }
	munin::check { 'exim_mailqueue': ensure => absent }
	munin::check { 'exim_mailstats': ensure => absent }

	munin::check { 'postfix_mailqueue': }
	munin::check { 'postfix_mailstats': }
	munin::check { 'postfix_mailvolume': }
	munin::check { 'ps_smtp': script => 'ps_' }
	munin::check { 'ps_smtpd': script => 'ps_' }

	if has_role('lists') {
		@ferm::rule { 'smtp':
			domain      => '(ip ip6)',
			description => 'Allow smtp access',
			rule        => '&SERVICE(tcp, 25)'
		}
	}
}
