class roles::security_upload {
	file { '/srv/security.upload.debian.org':
		ensure	=> directory,
		mode	=> '2755',
		owner	=> dak,
		group	=> debadmin,
	}
}
