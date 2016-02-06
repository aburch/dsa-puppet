class roles::static_mirror {

	include roles::static_source
	include apache2::cache

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

	$vhost_listen = $::hostname ? {
		klecker    => '130.89.148.14:80 [2001:610:1908:b000::148:14]:80',
		mirror-isc => '149.20.20.20:80 [2001:4f8:8:36::1deb:20]:80',
		mirror-anu => '150.203.164.62:80 [2001:388:1034:2900::3e]:80',
		default    => '*:80',
	}
	$vhost_listen_443 = $::hostname ? {
		klecker    => '130.89.148.14:443 [2001:610:1908:b000::148:14]:443',
		mirror-isc => '149.20.20.20:443 [2001:4f8:8:36::1deb:20]:443',
		mirror-anu => '150.203.164.62:443 [2001:388:1034:2900::3e]:443',
		default    => '*:443',
	}

	apache2::config { 'local-static-vhost.conf':
		content => template('roles/static-mirroring/static-vhost.conf.erb'),
	}

	apache2::site { '010-planet.debian.org':
		site    => 'planet.debian.org',
		content => template('roles/static-mirroring/vhost/planet.debian.org.erb'),
	}

	apache2::site { '010-lintian.debian.org':
		site    => 'lintian.debian.org',
		content => template('roles/static-mirroring/vhost/lintian.debian.org.erb'),
	}

	apache2::site { '010-static-vhosts-simple':
		site => 'static-vhosts-simple',
		content => template('roles/static-mirroring/vhost/static-vhosts-simple.erb'),
	}

	$wwwdo_document_root = '/srv/static.debian.org/mirrors/www.debian.org/cur'
	apache2::site { '005-www.debian.org':
		site   => 'www.debian.org',
		content => template('roles/apache-www.debian.org.erb'),
	}

	if has_static_component('dsa.debian.org'       ) { ssl::service { 'dsa.debian.org'      : notify => Service['apache2'], } }
	if has_static_component('www.debian.org'       ) { ssl::service { 'www.debian.org'      : notify => Service['apache2'], } }
	if has_static_component('bits.debian.org'      ) { ssl::service { 'bits.debian.org'     : notify => Service['apache2'], } }
	if has_static_component('lintian.debian.org'   ) { ssl::service { 'lintian.debian.org'  : notify => Service['apache2'], } }
	if has_static_component('rtc.debian.org'       ) { ssl::service { 'rtc.debian.org'      : notify => Service['apache2'], } }
	if has_static_component('appstream.debian.org' ) { ssl::service { 'appstream.debian.org': notify => Service['apache2'], } }
	if has_static_component('d-i.debian.org'       ) { ssl::service { 'd-i.debian.org'      : notify => Service['apache2'], } }

	if has_static_component('news.debian.net'     ) { ssl::service { 'news.debian.net'     : notify => Service['apache2'], key => true, } }
	if has_static_component('debaday.debian.net'  ) { ssl::service { 'debaday.debian.net'  : notify => Service['apache2'], key => true, } }
	if has_static_component('timeline.debian.net' ) { ssl::service { 'timeline.debian.net' : notify => Service['apache2'], key => true, } }
	if has_static_component('debconf0.debconf.org') { ssl::service { 'debconf0.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf1.debconf.org') { ssl::service { 'debconf1.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf2.debconf.org') { ssl::service { 'debconf2.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf3.debconf.org') { ssl::service { 'debconf3.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf4.debconf.org') { ssl::service { 'debconf4.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf5.debconf.org') { ssl::service { 'debconf5.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf6.debconf.org') { ssl::service { 'debconf6.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('debconf7.debconf.org') { ssl::service { 'debconf7.debconf.org': notify => Service['apache2'], key => true, } }
	if has_static_component('10years.debconf.org' ) { ssl::service { '10years.debconf.org' : notify => Service['apache2'], key => true, } }
	if has_static_component('es.debconf.org'      ) { ssl::service { 'es.debconf.org'      : notify => Service['apache2'], key => true, } }
	if has_static_component('fr.debconf.org'      ) { ssl::service { 'fr.debconf.org'      : notify => Service['apache2'], key => true, } }
	if has_static_component('miniconf10.debconf.org') { ssl::service { 'miniconf10.debconf.org': notify => Service['apache2'], key => true, } }
}
