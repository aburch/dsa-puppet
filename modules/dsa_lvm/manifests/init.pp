class dsa_lvm {
	case $::hostname {
		'ubc-bl8','ubc-bl4': {
			$conffile = 'lvm-ubc-ganeti.conf'
		}
		'ubc-bl3','ubc-bl7','ubc-bl2','ubc-bl6': {
			$conffile = 'lvm-ubc-ganeti-p410.conf'
		}
		'csail-node01','csail-node02': {
			$conffile = 'lvm-csail-nodeX-ganeti.conf'
		}
		'grnet-node01','grnet-node02': {
			$conffile = 'lvm-grnet-nodeX-ganeti.conf'
		}
		'bm-bl1','bm-bl2','bm-bl3','bm-bl4','bm-bl5','bm-bl6','bm-bl7','bm-bl8','bm-bl9','bm-bl10','bm-bl11','bm-bl12','bm-bl13','bm-bl14': {
			$conffile = 'lvm-bm-blades.conf'
		}
		'prokofiev': {
			$conffile = 'lvm-prokofiev.conf'
		}
		'clementi','czerny': {
			$conffile = 'lvm-manda-ganeti.conf'
		}
		'ubc-enc2bl01','ubc-enc2bl02','ubc-enc2bl09','ubc-enc2bl10': {
			$conffile = 'lvm-ubc-ganeti2.conf'
		}
		'aagaard','acker': {
			$conffile = 'lvm-conova-ganeti.conf'
		}
		default: {
			$conffile = ''
		}
	}

	if $conffile != '' {
		package { 'lvm2':
			ensure => installed,
		}

		file { '/etc/lvm/lvm.conf':
			ensure => file,
			source => "puppet:///modules/dsa_lvm/${conffile}",
		}
	}
}
