class roles::dgit_browse {
	ssl::service { 'browse.dgit.debian.org':
		notify  => Exec['service apache2 reload'],
		key => true,
	}

	package { 'cgit': ensure => installed, }
	package { 'python-pygments': ensure => installed, }
	package { 'python-chardet': ensure => installed, }

	file { '/etc/cgitrc':
		source => 'puppet:///modules/roles/dgit/cgitrc',
	}
	file { '/etc/apache2/conf-enabled/cgit.conf':
		ensure => absent,
		notify  => Exec['service apache2 reload'],
	}

	apache2::site { '010-browse.dgit.debian.org':
		site    => 'browse.dgit.debian.org',
		source => 'puppet:///modules/roles/dgit/browse.dgit.debian.org',
	}

}
