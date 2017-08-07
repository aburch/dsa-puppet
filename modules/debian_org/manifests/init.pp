# == Class: debian_org
#
# Stuff common to all debian.org servers
#
class debian_org {
	include debian_org::apt

	if $systemd {
		include systemd
		$servicefiles = 'present'
	} else {
		$servicefiles = 'absent'
	}

	$debianadmin = [
		'debian-archive-debian-samhain-reports@master.debian.org',
		'debian-admin@ftbfs.de',
		'weasel@debian.org',
		'steve@lobefin.net',
		'zumbi@oron.es'
	]

	package { [
			'klogd',
			'sysklogd',
			'rsyslog',
			'os-prober',
			'apt-listchanges',
			'mlocate',
		]:
		ensure => purged,
	}
	package { [
			'debian.org',
			'dsa-munin-plugins',
		]:
		ensure => installed,
		tag    => extra_repo,
	}
	file { '/etc/ssh/ssh_known_hosts':
		ensure  => present,
		replace => false,
		mode    => '0644',
		source  => 'puppet:///modules/debian_org/basic-ssh_known_hosts'
	}

	if versioncmp($::lsbmajdistrelease, '8') >= 0 {
		$rubyfs_package = 'ruby-filesystem'
	} else {
		$rubyfs_package = 'libfilesystem-ruby1.9'
	}
	package { [
			'apt-utils',
			'bash-completion',
			'dnsutils',
			'less',
			'lsb-release',
			$rubyfs_package,
			'mtr-tiny',
			'nload',
			'pciutils',
			'lldpd',
		]:
		ensure => installed,
	}

	munin::check { [
			'cpu',
			'entropy',
			'forks',
			'interrupts',
			'iostat',
			'irqstats',
			'load',
			'memory',
			'open_files',
			'open_inodes',
			'processes',
			'swap',
			'uptime',
			'vmstat',
		]:
	}

	if getfromhash($site::nodeinfo, 'broken-rtc') {
		package { 'fake-hwclock':
			ensure => installed,
			tag    => extra_repo,
		}
	}

	package { 'molly-guard':
		ensure => installed,
	}
	file { '/etc/molly-guard/run.d/10-check-kvm':
		mode    => '0755',
		source  => 'puppet:///modules/debian_org/molly-guard/10-check-kvm',
		require => Package['molly-guard'],
	}
	file { '/etc/molly-guard/run.d/15-acquire-reboot-lock':
		mode    => '0755',
		source  => 'puppet:///modules/debian_org/molly-guard/15-acquire-reboot-lock',
		require => Package['molly-guard'],
	}

	augeas { 'inittab_replicate':
		context => '/files/etc/inittab',
		changes => [
			'set ud/runlevels 2345',
			'set ud/action respawn',
			'set ud/process "/usr/bin/ud-replicated -d"',
		],
		notify  => Exec['init q'],
	}


	file { '/etc/facter':
		ensure  => directory,
		purge   => true,
		force   => true,
		recurse => true,
		source  => 'puppet:///files/empty/',
	}
	file { '/etc/facter/facts.d':
		ensure => directory,
	}
	file { '/etc/facter/facts.d/debian_facts.yaml':
		content => template('debian_org/debian_facts.yaml.erb')
	}
	file { '/etc/timezone':
		source => 'puppet:///modules/debian_org/timezone',
		notify => Exec['dpkg-reconfigure tzdata -pcritical -fnoninteractive'],
	}
	if $::hostname == handel {
		include puppetmaster::db
		$dbpassword = $puppetmaster::db::password
	}
	file { '/etc/puppet/puppet.conf':
		content => template('debian_org/puppet.conf.erb'),
		mode => '0440',
		group => 'puppet',
	}
	file { '/etc/default/puppet':
		source => 'puppet:///modules/debian_org/puppet.default',
	}
	file { '/etc/systemd':
		ensure  => directory,
		mode => '0755',
	}
	file { '/etc/systemd/system':
		ensure  => directory,
		mode => '0755',
	}
	file { '/etc/systemd/system/ud-replicated.service':
		ensure => $servicefiles,
		source => 'puppet:///modules/debian_org/ud-replicated.service',
		notify => Exec['systemctl daemon-reload'],
	}
	if $systemd {
		file { '/etc/systemd/system/multi-user.target.wants/ud-replicated.service':
			ensure => 'link',
			target => '../ud-replicated.service',
			notify => Exec['systemctl daemon-reload'],
		}
	}
	file { '/etc/systemd/system/puppet.service':
		ensure => 'link',
		target => '/dev/null',
		notify => Exec['systemctl daemon-reload'],
	}
	file { '/etc/systemd/system/proc-sys-fs-binfmt_misc.automount':
		ensure => 'link',
		target => '/dev/null',
		notify => Exec['systemctl daemon-reload'],
	}

	file { '/etc/cron.d/dsa-puppet-stuff':
		content => template('debian_org/dsa-puppet-stuff.cron.erb'),
		require => Package['debian.org'],
	}
	file { '/etc/ldap/ldap.conf':
		require => Package['debian.org'],
		content  => template('debian_org/ldap.conf.erb'),
	}
	file { '/etc/pam.d/common-session':
		require => Package['debian.org'],
		content => template('debian_org/pam.common-session.erb'),
	}
	file { '/etc/pam.d/common-session-noninteractive':
		require => Package['debian.org'],
		content => template('debian_org/pam.common-session-noninteractive.erb'),
	}
	file { '/etc/rc.local':
		mode   => '0755',
		content => template('debian_org/rc.local.erb'),
		notify => Exec['service rc.local restart'],
	}
	file { '/etc/dsa':
		ensure => directory,
		mode   => '0755',
	}
	file { '/etc/dsa/cron.ignore.dsa-puppet-stuff':
		source  => 'puppet:///modules/debian_org/dsa-puppet-stuff.cron.ignore',
		require => Package['debian.org']
	}
	file { '/etc/nsswitch.conf':
		mode   => '0755',
		source => 'puppet:///modules/debian_org/nsswitch.conf',
	}

	file { '/etc/profile.d/timeout.sh':
		mode   => '0555',
		source => 'puppet:///modules/debian_org/etc.profile.d/timeout.sh',
	}
	file { '/etc/zsh':
		ensure => directory,
	}
	file { '/etc/zsh/zprofile':
		mode   => '0444',
		source => 'puppet:///modules/debian_org/etc.zsh/zprofile',
	}

	# set mmap_min_addr to 4096 to mitigate
	# Linux NULL-pointer dereference exploits
	site::sysctl { 'mmap_min_addr':
		ensure => absent
	}
	site::sysctl { 'perf_event_paranoid':
		key   => 'kernel.perf_event_paranoid',
		value => '2',
	}
	site::sysctl { 'puppet-vfs_cache_pressure':
		key   => 'vm.vfs_cache_pressure',
		value => '10',
	}
	site::alternative { 'editor':
		linkto => '/usr/bin/vim.basic',
	}
	site::alternative { 'view':
		linkto => '/usr/bin/vim.basic',
	}
	mailalias { 'samhain-reports':
		ensure    => present,
		recipient => $debianadmin,
		require   => Package['debian.org']
	}

	file { '/usr/local/bin/check_for_updates':
		source => 'puppet:///modules/debian_org/check_for_updates',
		mode   => '0755',
		owner  => root,
		group  => root,
	}
	file { '/usr/local/bin/dsa-is-shutdown-scheduled':
		source	=> 'puppet:///modules/debian_org/dsa-is-shutdown-scheduled',
		mode	=> '0555',
	}

	exec { 'dpkg-reconfigure tzdata -pcritical -fnoninteractive':
		path        => '/usr/bin:/usr/sbin:/bin:/sbin',
		refreshonly => true
	}
	exec { 'service puppetmaster restart':
		refreshonly => true
	}
	exec { 'service rc.local restart':
		refreshonly => true
	}
	exec { 'init q':
		refreshonly => true
	}

	exec { 'systemctl daemon-reload':
		refreshonly => true,
		onlyif  => "test -x /bin/systemctl"
	}

	exec { 'systemd-tmpfiles --create --exclude-prefix=/dev':
		refreshonly => true,
		onlyif  => "test -x /bin/systemd-tmpfiles"
	}

	tidy { '/var/lib/puppet/clientbucket/':
		age      => '2w',
		recurse  => 9,
		type     => ctime,
		matches  => [ 'paths', 'contents' ],
		schedule => weekly
	}

	file { '/root/.bashrc':
		source => 'puppet:///modules/debian_org/root-dotfiles/bashrc',
	}
	file { '/root/.profile':
		source => 'puppet:///modules/debian_org/root-dotfiles/profile',
	}
	file { '/root/.selected_editor':
		source => 'puppet:///modules/debian_org/root-dotfiles/selected_editor',
	}
	file { '/root/.screenrc':
		source => 'puppet:///modules/debian_org/root-dotfiles/screenrc',
	}
	file { '/root/.tmux.conf':
		source => 'puppet:///modules/debian_org/root-dotfiles/tmux.conf',
	}
	file { '/root/.vimrc':
		source => 'puppet:///modules/debian_org/root-dotfiles/vimrc',
	}
}
