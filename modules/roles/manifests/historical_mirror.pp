class roles::historical_mirror {
	include roles::archvsync_base
	include apache2::expires

	$binds = $::hostname ? {
		gretchaninov  => ['209.87.16.41'   , '[2607:f8f0:614:1::1274:41]'          ],
		klecker       => ['130.89.148.13'  , '[2001:610:1908:b000::148:13]',
		                  '[2001:67c:2564:a119::148:13]' ],
		mirror-conova => ['217.196.149.234', '[2a02:16a8:dc41:100::234]'           ],
		sibelius      => ['193.62.202.28'  , '[2001:630:206:4000:1a1a:0:c13e:ca1c]'],
		default       => ['[::]'],
	}

	$onion_v4_addr = $::hostname ? {
		default    => undef,
	}
	$archive_root = $::hostname ? {
		default    => '/srv/mirrors/debian-archive',
	}

	apache2::site { '010-archive.debian.org':
		site   => 'archive.debian.org',
		content => template('roles/apache-archive.debian.org.erb'),
	}

	if has_role('historical_master') {
		$sslname = 'archive-master.debian.org'
		ssl::service { $sslname:
			key      => true,
			tlsaport => [],
		}
	} else {
		$sslname = undef
	}

	rsync::site { 'archive':
		source      => 'puppet:///modules/roles/historical_mirror/rsyncd.conf',
		max_clients => 100,
		sslname     => $sslname,
		binds       => $binds,
	}

	if has_role('historical_mirror_onion') {
		if ! $onion_v4_addr {
			fail("Do not have an onion_v4_addr set for $::hostname.")
		}

		onion::service { 'archive.debian.org':
			port => 80,
			target_port => 80,
			target_address => $onion_v4_addr,
		}
	}
}
