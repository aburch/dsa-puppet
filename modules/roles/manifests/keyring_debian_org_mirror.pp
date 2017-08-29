class roles::keyring_debian_org_mirror {
	file { '/srv/keyring.debian.org/keyrings':
		ensure => 'directory'
	}
	file { '/srv/keyring.debian.org/keyrings/debian-keyring.gpg':
		ensure => 'link',
		target => '/var/lib/misc/thishost/debian-keyring.gpg'
	}
	file { '/srv/keyring.debian.org/keyrings/debian-maintainers.gpg':
		ensure => 'link',
		target => '/var/lib/misc/thishost/debian-maintainers.gpg'
	}
	file { '/srv/keyring.debian.org/keyrings/debian-nonupload.gpg':
		ensure => 'link',
		target => '/var/lib/misc/thishost/debian-nonupload.gpg'
	}

	file { '/srv/keyring.debian.org/keyrings/buildd-keyrings':
		ensure => 'link',
		target => '/var/lib/misc/thishost/buildd-keyrings'
	}
}
