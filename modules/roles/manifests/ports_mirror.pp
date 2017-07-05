class roles::ports_mirror {
	include roles::archvsync_base

	$vhost_listen = $::hostname ? {
		klecker    => '130.89.148.14:80 [2001:610:1908:b000::148:14]:80 [2001:67c:2564:a119::148:14]:80',
		mirror-isc => '149.20.4.15:80 [2001:4f8:1:c::15]:80',
		default => '*:80',
	}
	$onion_v4_addr = $::hostname ? {
		klecker    => '130.89.148.14',
		mirror-isc => '149.20.4.15',
		default    => undef,
	}

	apache2::site { '010-ftp.ports.debian.org':
		site   => 'ftp.ports.debian.org',
		content => template('roles/apache-ftp.ports.debian.org.erb'),
	}

	if has_role('static_mirror_onion') {
		if ! $onion_v4_addr {
			fail("Do not have an onion_v4_addr set for $::hostname.")
		}

		onion::service { 'ftp.ports.debian.org':
			port => 80,
			target_port => 80,
			target_address => $onion_v4_addr,
		}
	}
}
