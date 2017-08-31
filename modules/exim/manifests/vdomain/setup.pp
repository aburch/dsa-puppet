class exim::vdomain::setup {

	concat { '/etc/exim4/virtualdomains':
		owner   => root,
		group   => root,
		mode    => '0644',
		require => Package['exim4-daemon-heavy']
	}

	concat::fragment { 'virtualdomains_header':
		target => '/etc/exim4/virtualdomains',
		content => template('exim/virtualdomains.header.erb'),
		order  => '00',
	}
}
