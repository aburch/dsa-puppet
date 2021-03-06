class grub {
	$grub_do_ifnames = ($::kernel == 'Linux' and $::is_virtual and $::virtual == 'kvm')

	if ($::kernel == 'Linux' and $::is_virtual and $::virtual == 'kvm') {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = true
	} elsif $::hostname in [ubc-enc2bl01,ubc-enc2bl02,ubc-enc2bl09,ubc-enc2bl10,casulana,mirror-anu,sallinen,storace,mirror-accumu,bm-bl1,bm-bl2,bm-bl3,bm-bl4,bm-bl5,bm-bl6,bm-bl7,bm-bl8,bm-bl9,bm-bl10,bm-bl11,bm-bl12,bm-bl13,bm-bl14] {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = true
	} elsif $::hostname in [mirror-skroutz,aagaard,acker,arm-arm-01,fasolo] {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = true
	} elsif $::hostname in [acker,arm-arm-03] {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = false
	} else {
		$grub_manage = false
	}

	$grub_do_nopat = $::hostname in [ubc-enc2bl01,ubc-enc2bl02,ubc-enc2bl09,ubc-enc2bl10,casulana,mirror-anu,sallinen,storace,mirror-accumu,bm-bl1,bm-bl2,bm-bl3,bm-bl4,bm-bl5,bm-bl6,bm-bl7,bm-bl8,bm-bl9,bm-bl10,bm-bl11,bm-bl12,bm-bl13,bm-bl14]
	$grub_do_extra = $::hostname in [fasolo]

	if $grub_manage {
		file { '/etc/default/grub':
			# restore to default
			source => 'puppet:///modules/grub/etc-default-grub',
			notify  => Exec['update-grub']
		}

		file { '/etc/default/grub.d':
			ensure => directory,
			mode   => '0555',
			purge   => true,
			force   => true,
			recurse => true,
			source  => 'puppet:///files/empty/',
		}

		file { '/etc/default/grub.d/puppet-grub-serial.cfg':
			ensure => $grub_do_kernel_serial ? { true  => 'present', default => 'absent' },
			content  => template('grub/puppet-grub-serial.cfg.erb'),
			notify  => Exec['update-grub']
		}

		file { '/etc/default/grub.d/puppet-kernel-serial.cfg':
			ensure => $grub_do_grub_serial ? { true  => 'present', default => 'absent' },
			content  => template('grub/puppet-kernel-serial.cfg.erb'),
			notify  => Exec['update-grub']
		}

		file { '/etc/default/grub.d/puppet-net-ifnames.cfg':
			ensure => $grub_do_ifnames ? { true  => 'present', default => 'absent' },
			content  => template('grub/puppet-net-ifnames.cfg.erb'),
			notify  => Exec['update-grub']
		}

		file { '/etc/default/grub.d/puppet-kernel-nopat.cfg':
			ensure => $grub_do_nopat ? { true  => 'present', default => 'absent' },
			content  => template('grub/puppet-kernel-nopat.cfg.erb'),
			notify  => Exec['update-grub']
		}

		file { '/etc/default/grub.d/puppet-kernel-extra.cfg':
			ensure => $grub_do_extra ? { true  => 'present', default => 'absent' },
			content  => template('grub/puppet-kernel-extra.cfg.erb'),
			notify  => Exec['update-grub']
		}
	}

	exec { 'update-grub':
		refreshonly => true,
		path        => '/usr/bin:/usr/sbin:/bin:/sbin',
	}
}
