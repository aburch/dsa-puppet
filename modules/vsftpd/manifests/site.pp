define vsftpd::site (
	$root,
	$binds=['[::]'],
	$chown_user='',
	$writable=false,
	$writable_other=false,
	$readable=true,
	$listable=true,
	$banner="${name} FTP Server",
	$max_clients=100,
	$logfile="/var/log/ftp/vsftpd-${name}.debian.org.log",
	$ensure=present,
) {
	include vsftpd
	include ferm::ftp_conntrack

	case $ensure {
		present,absent: {}
		default: { fail ( "Invald ensure `$ensure' for $name" ) }
	}

	$ensure_service = $ensure ? {
		present => running,
		absent  => stopped,
	}

	$ensure_enable = $ensure ? {
		present => true,
		absent  => false,
	}

	$ftpsite = $name

	$fname = "/etc/vsftpd-${name}.conf"

	file { $fname:
		ensure  => $ensure,
		content => template('vsftpd/vsftpd.conf.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => '0444',
	}

	file { "/etc/logrotate.d/vsftpd-${name}":
		ensure => absent
	}

	file { "/etc/systemd/system/vsftpd-${name}@.service":
		ensure  => $ensure,
		content => template('vsftpd/systemd-vsftpd.service.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => '0444',
		require => File[$fname],
		notify  => Exec['systemctl daemon-reload'],
	}

	file { "/etc/systemd/system/vsftpd-${name}.socket":
		ensure  => $ensure,
		content => template('vsftpd/systemd-vsftpd.socket.erb'),
		owner   => 'root',
		group   => 'root',
		mode    => '0444',
		notify  => [
			Exec['systemctl daemon-reload'],
			Service["vsftpd-${name}.socket"],
		],
	}

	service { "vsftpd-${name}.socket":
		ensure   => $ensure_service,
		enable   => $ensure_enable,
		require  => [
			Exec['systemctl daemon-reload'],
			File["/etc/systemd/system/vsftpd-${name}@.service"],
			File["/etc/systemd/system/vsftpd-${name}.socket"],
		],
		provider => systemd,
	}

	munin::check { "vsftpd-${name}":
		ensure => $ensure,
		script => 'vsftpd'
	}
	munin::conf { "vsftpd-${name}":
		ensure  => $ensure,
		content => template('vsftpd/munin.erb')
	}
}
