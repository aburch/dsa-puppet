class autofs::ubc {
	include autofs::common

	file { '/etc/auto.master.d/dsa.autofs':
		source  => "puppet:///modules/autofs/ubc/auto.master.d-dsa.autofs",
		notify  => Exec['autofs reload']
	}
	file { '/etc/auto.dsa':
		source  => "puppet:///modules/autofs/ubc/auto.dsa",
		notify  => Exec['autofs reload']
	}

	file { '/srv/mirrors': ensure  => directory }
	file { '/srv/mirrors/debian': ensure  => '/auto.dsa/debian' }
	file { '/srv/mirrors/debian-backports': ensure  => absent }
	file { '/srv/mirrors/debian-ports': ensure  => '/auto.dsa/debian-ports' }
}
