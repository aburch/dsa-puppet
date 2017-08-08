class hardware::raid::dell {
	site::aptrepo { 'jessie.dell':
		url        => 'http://deb.debian.org/debian',
		suite      => 'jessie',
		components => 'main',
	}
	site::aptrepo { 'debian.restricted.dell':
		url        => 'http://db.debian.org/debian-admin',
		suite      => 'jessie-restricted',
		components => 'non-free',
	}

	package { 'libssl1.0.0':
		ensure	=> installed,
	}
	package { 'srvadmin-storage-cli':
		ensure  => installed,
		tag    => extra_repo,
	}
}
