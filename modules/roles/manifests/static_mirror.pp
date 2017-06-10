class roles::static_mirror {

	include roles::static_source
	include apache2::expires
	include apache2::rewrite

	package { 'libapache2-mod-geoip': ensure => installed, }
	package { 'geoip-database': ensure => installed, }

	include apache2::ssl
	apache2::module { 'include': }
	apache2::module { 'geoip': require => [Package['libapache2-mod-geoip'], Package['geoip-database']]; }

	file { '/usr/local/bin/static-mirror-run':
		source => 'puppet:///modules/roles/static-mirroring/static-mirror-run',
		mode   => '0555',
	}

	file { '/usr/local/bin/static-mirror-run-all':
		source => 'puppet:///modules/roles/static-mirroring/static-mirror-run-all',
		mode   => '0555',
	}

	file { '/srv/static.debian.org':
		ensure => directory,
		owner  => staticsync,
		group  => staticsync,
		mode   => '02755'
	}

	file { '/etc/cron.d/puppet-static-mirror':
			content => "MAILTO=root\nPATH=/usr/local/bin:/usr/bin:/bin\n@reboot staticsync sleep 60; chronic static-mirror-run-all\n",
	}

	$onion_v4_addr = $::hostname ? {
		busoni     => '140.211.166.202',
		klecker    => '130.89.148.14',
		mirror-isc => '149.20.4.15',
		senfter    => '5.153.231.4',
		default    => undef,
	}
	$vhost_listen = $::hostname ? {
		klecker    => '130.89.148.14:80 [2001:610:1908:b000::148:14]:80',
		mirror-isc => '149.20.4.15:80 [2001:4f8:1:c::15]:80',
		mirror-anu => '150.203.164.62:80 [2001:388:1034:2900::3e]:80',
		default    => '*:80',
	}
	$vhost_listen_443 = $::hostname ? {
		klecker    => '130.89.148.14:443 [2001:610:1908:b000::148:14]:443',
		mirror-isc => '149.20.4.15:443 [2001:4f8:1:c::15]:443',
		mirror-anu => '150.203.164.62:443 [2001:388:1034:2900::3e]:443',
		default    => '*:443',
	}

	apache2::config { 'local-static-vhost.conf':
		ensure => absent,
	}
	apache2::config { 'local-static-vhost':
		content => template('roles/static-mirroring/static-vhost.conf.erb'),
	}

	apache2::site { '010-planet.debian.org':
		site    => 'planet.debian.org',
		ensure  => has_static_component('planet.debian.org') ? { true => "present", false => "absent" },
		content => template('roles/static-mirroring/vhost/planet.debian.org.erb'),
	}

	apache2::site { '010-lintian.debian.org':
		site    => 'lintian.debian.org',
		ensure  => absent,
	}

	apache2::site { '010-static-vhosts-00-manpages':
		site   => 'static-manpages.debian.org',
		ensure  => has_static_component('manpages.debian.org') ? { true => "present", false => "absent" },
		content => template('roles/static-mirroring/vhost/manpages.debian.org.erb'),
	}
	apache2::site { '010-static-vhosts-simple':
		site => 'static-vhosts-simple',
		content => template('roles/static-mirroring/vhost/static-vhosts-simple.erb'),
	}

	$wwwdo_document_root = '/srv/static.debian.org/mirrors/www.debian.org/cur'
	apache2::site { '005-www.debian.org':
		site   => 'www.debian.org',
		ensure  => has_static_component('www.debian.org') ? { true => "present", false => "absent" },
		content => template('roles/apache-www.debian.org.erb'),
	}

	ssl::service { 'www.debian.org'      : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debian.org' :
		ensure  => has_static_component('www.debian.org') ? { true => "present", false => "absent" },
		notify  => Exec['service apache2 reload'],
		key => true,
	}

	# do
	ssl::service { 'appstream.debian.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'apt.buildd.debian.org'         : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'backports.debian.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'bits.debian.org'               : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'blends.debian.org'             : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'd-i.debian.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true }
	ssl::service { 'deb.debian.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true }
	ssl::service { 'dpl.debian.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true }
	ssl::service { 'dsa.debian.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true }
	ssl::service { 'incoming.debian.org'           : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'incoming.ports.debian.org'     : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'lintian.debian.org'            : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'manpages.debian.org'           : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'mirror-master.debian.org'      : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'onion.debian.org'              : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'release.debian.org'            : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'rtc.debian.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true }
	ssl::service { 'security-team.debian.org'      : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'www.ports.debian.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	# dn
	ssl::service { 'bootstrap.debian.net'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debaday.debian.net'            : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debdeltas.debian.net'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'micronews.debian.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'mozilla.debian.net'            : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'news.debian.net'               : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'timeline.debian.net'           : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'wnpp-by-tags.debian.net'       : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	# dc
	ssl::service { '10years.debconf.org'           : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf0.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf1.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf16.debconf.org'         : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf2.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf3.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf4.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf5.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf6.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'debconf7.debconf.org'          : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'es.debconf.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'fr.debconf.org'                : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }
	ssl::service { 'miniconf10.debconf.org'        : ensure => "ifstatic", notify  => Exec['service apache2 reload'], key => true, }

	if has_role('static_mirror_onion') {
		if ! $onion_v4_addr {
			fail("Do not have an onion_v4_addr set for $::hostname.")
		}

		onion::service { 'd-i.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'dpl.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'dsa.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'rtc.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'www.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }

		# do
		onion::service { 'appstream.debian.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'apt.buildd.debian.org'         : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'backports.debian.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'bits.debian.org'               : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'blends.debian.org'             : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'incoming.debian.org'           : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'incoming.ports.debian.org'     : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'lintian.debian.org'            : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'manpages.debian.org'           : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'mirror-master.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'onion.debian.org'              : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'release.debian.org'            : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'security-team.debian.org'      : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'www.ports.debian.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		# dn
		onion::service { 'bootstrap.debian.net'           : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debaday.debian.net'            : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debdeltas.debian.net'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'micronews.debian.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'mozilla.debian.net'            : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'news.debian.net'               : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'timeline.debian.net'           : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'wnpp-by-tags.debian.net'       : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		# dc
		onion::service { '10years.debconf.org'           : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf0.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf1.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf16.debconf.org'         : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf2.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf3.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf4.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf5.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf6.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'debconf7.debconf.org'          : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'es.debconf.org'                : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'fr.debconf.org'                : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'miniconf10.debconf.org'        : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }

		# non-SSL
		onion::service { 'metadata.ftp-master.debian.org': ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
		onion::service { 'planet.debian.org'             : ensure => "ifstatic", port => 80, target_port => 80, target_address => $onion_v4_addr }
	}

	file { '/srv/static.debian.org/puppet':
		ensure => directory,
		mode   => '02755'
	}
	file { '/srv/static.debian.org/puppet/disabled-service':
		ensure => directory,
		mode   => '02755'
	}
	file { '/srv/static.debian.org/puppet/disabled-service/503.html':
		source => 'puppet:///modules/roles/static-htdocs/disabled-service/503.html',
	}

	ssl::service { 'archive.debian.net': ensure => present, notify  => Exec['service apache2 reload'], key => true, }
	file { '/srv/static.debian.org/puppet/archive.debian.net':
		ensure => absent,
	}
	file { '/srv/static.debian.org/puppet/archive.debian.net/503.html':
		ensure => absent,
	}

}
