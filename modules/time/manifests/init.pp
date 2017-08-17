class time {
	include stdlib
	$localtimeservers = hiera('local-timeservers', [])
	$physicalHost = $site::allnodeinfo[$fqdn]['physicalHost']

	# if ($::kernel == 'Linux' and $::is_virtual and $::virtual == 'kvm'
	#if ($systemd and $physicalHost and size($localtimeservers) > 0) {
	if ($systemd and size($localtimeservers) > 0 and $::virt == 'kvm') {
		include ntp::purge
		include systemdtimesyncd
	} else {
		include ntp
		include ntpdate
	}
}
