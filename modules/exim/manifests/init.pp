class exim {

	$is_mailrelay = has_role('mailrelay')
	$is_bugsmaster = has_role('bugsmaster')
	$is_bugsmx = has_role('bugsmx')
	$is_rtmaster = has_role('rtmaster')
	$is_packagesmaster = has_role('packagesmaster')
	$is_packagesqamaster = has_role('packagesqamaster')

	include exim::vdomain::setup
	include debian_org::mail_incoming_port

	munin::check { 'ps_exim4': script => 'ps_' }
	munin::check { 'exim_mailqueue': }
	munin::check { 'exim_mailstats': }

	munin::check { 'postfix_mailqueue':  ensure => absent }
	munin::check { 'postfix_mailstats':  ensure => absent }
	munin::check { 'postfix_mailvolume': ensure => absent }

	package { 'exim4-daemon-heavy': ensure => installed }

	Package['exim4-daemon-heavy']->Mailalias<| |>

	concat::fragment { 'virtual_domain_template':
		target  => '/etc/exim4/virtualdomains',
		content => template('exim/virtualdomains.erb'),
		order   => '05',
	}

	service { 'exim4':
		ensure  => running,
		require => [
			File['/etc/exim4/exim4.conf'],
			Package['exim4-daemon-heavy'],
		]
	}

	file { '/etc/exim4/':
		ensure  => directory,
		mode    => '0755',
		require => Package['exim4-daemon-heavy'],
		purge   => true,
	}
	file { '/etc/exim4/Git':
		ensure  => absent,
		force   => true,
	}
	file { '/etc/exim4/conf.d':
		ensure  => directory,
		purge   => true,
		force   => true,
		recurse => true,
		source  => 'puppet:///files/empty/',
	}
	file { '/etc/exim4/ssl':
		ensure  => directory,
		group   => 'Debian-exim',
		mode    => '0750',
		purge   => true,
	}
	file { '/etc/exim4/exim4.conf':
		content => template('exim/eximconf.erb'),
		require => File['/etc/exim4/ssl/thishost.crt'],
		notify  => Service['exim4'],
	}
	file { '/etc/mailname':
		content => template('exim/mailname.erb'),
	}
	file { '/etc/exim4/manualroute':
		content => template('exim/manualroute.erb')
	}
	file { '/etc/exim4/locals':
		content => template('exim/locals.erb')
	}
	file { '/etc/exim4/submission-domains':
		content => template('exim/submission-domains.erb'),
	}
	file { '/etc/exim4/host_blacklist':
		source => 'puppet:///modules/exim/common/host_blacklist',
	}
	file { '/etc/exim4/blacklist':
		source => 'puppet:///modules/exim/common/blacklist',
	}
	file { '/etc/exim4/callout_users':
		source => 'puppet:///modules/exim/common/callout_users',
	}
	file { '/etc/exim4/grey_users':
		source => 'puppet:///modules/exim/common/grey_users',
	}
	file { '/etc/exim4/helo-check':
		source => 'puppet:///modules/exim/common/helo-check',
	}
	file { '/etc/exim4/localusers':
		source => 'puppet:///modules/exim/common/localusers',
	}
	file { '/etc/exim4/rbllist':
		source => 'puppet:///modules/exim/common/rbllist',
	}
	file { '/etc/exim4/rhsbllist':
		source => 'puppet:///modules/exim/common/rhsbllist',
	}
	file { '/etc/exim4/whitelist':
		source => 'puppet:///modules/exim/common/whitelist',
	}
	file { '/etc/logrotate.d/exim4-base':
		source => 'puppet:///modules/exim/common/logrotate-exim4-base',
	}
	file { '/etc/logrotate.d/exim4-paniclog':
		source => 'puppet:///modules/exim/common/logrotate-exim4-paniclog'
	}
	file { '/etc/exim4/ssl/thishost.crt':
		source  => "puppet:///modules/exim/certs/${::fqdn}.crt",
		group   => 'Debian-exim',
		mode    => '0640',
	}
	file { '/etc/exim4/ssl/thishost.key':
		source  => "puppet:///modules/exim/certs/${::fqdn}.key",
		group   => 'Debian-exim',
		mode    => '0640',
	}
	file { '/etc/exim4/ssl/ca.crt':
		source  => 'puppet:///modules/exim/certs/ca.crt',
		group   => 'Debian-exim',
		mode    => '0640',
	}
	file { '/etc/exim4/ssl/ca.crl':
		source  => 'puppet:///modules/exim/certs/ca.crl',
		group   => 'Debian-exim',
		mode    => '0640',
	}
	file { '/var/log/exim4':
		ensure  => directory,
		mode    => '2750',
		owner   => 'Debian-exim',
		group   => maillog,
	}

	# Do we actually want this?  I'm only doing it because it's harmless
	# and makes the logs quiet.  There are better ways of making logs quiet,
	# though.
	@ferm::rule { 'dsa-ident':
		domain      => '(ip ip6)',
		description => 'Allow ident access',
		rule        => '&SERVICE(tcp, 113)'
	}

	# These only affect the alias @$fqdn, not say, @debian.org

	mailalias { [
		'postmaster',
		'hostmaster',
		'usenet',
		'webmaster',
		'abuse',
		'noc',
		'security',
	]:
		ensure => absent
	}
}
