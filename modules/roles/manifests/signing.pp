class roles::signing {
	package { 'expect': ensure => installed, }
	package { 'pesign': ensure => installed, }
	package { 'linux-kbuild-4.9': ensure => installed, }
	package { 'libengine-pkcs11-openssl': ensure => installed, }

	file { '/usr/local/bin/pesign-wrap':
		owner => 'root',
		group => 'root',
		mode => '0555',
		source => 'puppet:///modules/roles/signing/pesign-wrap',
	}

	file { '/usr/local/bin/secure-boot-code-sign':
		owner => 'root',
		group => 'root',
		mode => '0555',
		source => 'puppet:///modules/roles/signing/secure-boot-code-sign.py',
	}
}
