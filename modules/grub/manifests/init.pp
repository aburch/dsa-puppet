class grub {
	if ($::kernel == 'Linux' and $::is_virtual and $::virtual == 'kvm') {
		file { '/etc/default/grub':
			content  => template('grub/etc-default-grub.erb'),
			notify  => Exec['update-grub']
		}

		exec { 'update-grub':
			refreshonly => true,
			path        => '/usr/bin:/usr/sbin:/bin:/sbin',
		}
	}
}
