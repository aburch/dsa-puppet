class grub {
	if ($::kernel == 'Linux' and $::is_virtual and $::virtual == 'kvm') {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = true
		$grub_do_ifnames = true
	} elsif $::hostname in [ubc-enc2bl01,ubc-enc2bl02,ubc-enc2bl09,ubc-enc2bl10,casulana,mirror-anu,sallinen,storace,mirror-accumu] {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = true
		$grub_do_nopat = true
	} elsif $::hostname in [mirror-skroutz,aagaard,acker,arm-arm-01,fasolo] {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = true
		$grub_do_nopat = false
	} elsif $::hostname in [acker,arm-arm-03] {
		$grub_manage = true
		$grub_do_kernel_serial = true
		$grub_do_grub_serial = false
		$grub_do_nopat = false
	} else {
		$grub_manage = false
	}

	if $::hostname in [fasolo] {
		$grub_do_extra = true
	} else {
		$grub_do_extra = false
	}

	if $grub_manage {
		file { '/etc/default/grub':
			# restore to default
			source => 'puppet:///modules/grub/etc-default-grub',
			notify  => Exec['update-grub']
		}

		file { '/etc/default/grub.d':
			ensure => directory
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
