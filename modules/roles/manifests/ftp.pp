class roles::ftp {
	# this is the FTP part of the roles::debian_mirror class

	$binds = $::hostname ? {
		klecker => [ '130.89.148.12', '[2001:610:1908:b000::148:12]', '[2001:67c:2564:a119::148:12]' ],
		default => [ '[::]' ],
	}

	vsftpd::site { 'ftp':
		banner       => 'ftp.debian.org FTP server',
		logfile      => '/var/log/ftp/vsftpd-ftp.debian.org.log',
		binds        => $binds,
		max_clients  => 200,
		root         => '/srv/ftp.debian.org/ftp.root',
	}
}
