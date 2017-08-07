Package {
	require => File['/etc/apt/apt.conf.d/local-recommends']
}

File {
	owner  => root,
	group  => root,
	mode   => '0444',
	ensure => file,
}

Exec {
	path => '/usr/bin:/usr/sbin:/bin:/sbin'
}

Service {
	hasrestart => true,
	hasstatus  => true,
}

node default {
	include site
	include munin
	include syslog_ng
	include sudo
	include ssh
	include debian_org
	include monit
	include time
	include ssl
	include hardware
	include nagios::client
	include resolv
	include roles
	include motd
	include unbound
	include bacula::client
	include autofs
	include dsa_lvm
	include grub
	include multipath
	include popcon
	include portforwarder
	include postgres
	include haveged

	if $::lsbdistcodename == squeeze {
		include roles::udldap::client
	} else {
		include roles::pubsub::client
		class { 'roles::udldap::client':
			ensure => absent
		}
	}

	if $::hostname in [ubc-bl7,ubc-bl3,ubc-bl2,ubc-bl6,ubc-bl8,ubc-bl4,byrd,clementi,czerny,bm-bl1,bm-bl2,bm-bl3,bm-bl4,bm-bl5,bm-bl6,bm-bl7,bm-bl8,bm-bl9,bm-bl10,bm-bl11,bm-bl12,bm-bl13,bm-bl14,csail-node01,csail-node02,grnet-node01,grnet-node02,ubc-enc2bl01,ubc-enc2bl02,ubc-enc2bl09,ubc-enc2bl10,aagaard,acker] {
		include ganeti2
	}

	if $::kernel == 'Linux' {
		include linux
		include acpi
	} elsif $::kernel == 'GNU/kFreeBSD' {
		include kfreebsd
	}

	if $::mta == 'exim4' {
		if getfromhash($site::nodeinfo, 'heavy_exim') {
			include exim::mx
		} else {
			include exim
		}
	} elsif $::mta == 'postfix' {
		include postfix
	} else {
		include exim
	}

	if $::apache2 {
		include apache2
	}

	if $::hostname in [geo1,geo2,geo3] {
		include named::geodns
	}

	if $::hostname in [buxtehude,milanollo,lw01,lw02,lw03,lw04,senfter,gretchaninov,sibelius] {
		include nfs_server
	}

	if $::brokenhosts {
		include hosts
	}

	if $::samhain {
		include samhain
	}

	if $::hostname in [geo3,wieck] {
		include debian_org::radvd
	}

	if $::spamd {
		munin::check { 'spamassassin': }
	}

	if $::hostname == 'pkgmirror-csail' {
		include varnish
	}
}
