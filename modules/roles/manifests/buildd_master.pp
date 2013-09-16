class roles::buildd_master {
	include apache2::macro

	apache2::site { '010-buildd.debian.org':
		site   => 'buildd.debian.org',
		source => 'puppet:///modules/roles/buildd_master/apache.conf'
	}
	ssl::service { 'buildd.debian.org':
		notify => Service['apache2'],
	}
}
