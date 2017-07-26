# = Class: motd
#
# This class configures a sensible motd
#
# == Sample Usage:
#
#   include motd
#
class motd {
	file { '/etc/update-motd.d':
		ensure => directory,
		mode   => '0755'
	}
	file { '/etc/motd.tail':
		ensure => absent,
	}

	if versioncmp($::lsbmajdistrelease, '9') < 0 {
		file { '/etc/motd':
			ensure => link,
			target => '/var/run/motd'
		}
	} else {
		file { '/etc/motd':
			ensure => link,
			target => '/run/motd.dynamic'
		}
	}

	file { '/etc/update-motd.d/puppet-motd':
		notify  => undef,
		mode    => '0555',
		content => template('motd/motd.erb')
	}

	exec { 'updatemotd':
		command     => 'uname -snrvm > /var/run/motd && cat /etc/motd.tail >> /var/run/motd',
		refreshonly => true,
	}
}
