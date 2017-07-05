class roles::debian_mirror {
	include roles::archvsync_base

	$vhost_listen = join([
		$::hostname ? {
			klecker    => '130.89.148.12:80 [2001:610:1908:b000::148:12]:80 [2001:67c:2564:a119::148:12]:80',
			mirror-bytemark => '5.153.231.45:80 [2001:41c8:1000:21::21:45]:80',
			mirror-isc => '149.20.4.15:80 [2001:4f8:1:c::15]:80',
			mirror-conova => '217.196.149.232:80 [2a02:16a8:dc41:100::232]:80',
			default => '*:80',
		},
		has_role('bgp') ? {
			true => '193.31.7.2:80 [2a02:158:ffff:deb::2]:80',
			default => '',
		}], ' ')
	$onion_v4_addr = $::hostname ? {
		mirror-bytemark => '5.153.231.45',
		klecker    => '130.89.148.12',
		mirror-isc => '149.20.4.15',
		default    => undef,
	}
	$archive_root = $::hostname ? {
		default    => '/srv/mirrors/debian',
	}

	apache2::site { '010-ftp.debian.org':
		site   => 'ftp.debian.org',
		content => template('roles/apache-ftp.debian.org.erb'),
	}

	if has_role('debian_mirror_onion') {
		if ! $onion_v4_addr {
			fail("Do not have an onion_v4_addr set for $::hostname.")
		}

		onion::service { 'ftp.debian.org':
			port => 80,
			target_port => 80,
			target_address => $onion_v4_addr,
		}
	}
}
