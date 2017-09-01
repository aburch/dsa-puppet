class roles::security_upload {
	file { '/srv/security.upload.debian.org':
		ensure	=> directory,
		mode	=> '2755',
		owner	=> dak,
		group	=> debadmin,
	}

	vsftpd::site { 'security-upload':
		banner     => 'ftp.security.upload.debian.org FTP server',
		logfile    => '/var/log/ftp/vsftpd-security.upload.debian.org.log',
		writable   => true,
		chown_user => dak-unpriv,
		root       => '/srv/security.upload.debian.org/ftp',
	}
}
