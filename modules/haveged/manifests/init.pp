class haveged {
	$ensure = ($::haveged) ? {
		true    => 'present',
		default => 'absent'
	}


	if ($haveged) {
		service { 'haveged':
			ensure => running,
		}
	}

	# work around #858134
	systemd::override { 'haveged':
		content => @(EOT)
			[Unit]
			After=systemd-tmpfiles-setup.service
			| EOT
	}
}
