class grub {
	if ($::kernel == 'Linux' and $::is_virtual and $::virtual == 'kvm') {
		file { '/etc/default/grub':
			# restore to default
			source => 'puppet:///modules/grub/etc-default-grub',
			notify  => Exec['update-grub']
		}
		file { '/etc/default/grub.d':
			ensure => directory
		}
		file { '/etc/default/grub.d/puppet-grub-serial.cfg':
			content  => template('grub/puppet-grub-serial.cfg.erb'),
			notify  => Exec['update-grub']
		}
		file { '/etc/default/grub.d/puppet-net-ifnames.cfg':
			content  => template('grub/puppet-net-ifnames.cfg.erb'),
			notify  => Exec['update-grub']
		}

		exec { 'update-grub':
			refreshonly => true,
			path        => '/usr/bin:/usr/sbin:/bin:/sbin',
		}
	}
}
