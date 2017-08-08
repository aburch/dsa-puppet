class hardware::raid::dell {
	site::aptrepo { 'debian.restricted.dell':
		url        => 'http://db.debian.org/debian-admin',
		suite      => 'jessie-restricted',
		components => 'non-free',
	}

	package { 'srvadmin-all':
		ensure  => installed,
		tag    => extra_repo,
	}
}
