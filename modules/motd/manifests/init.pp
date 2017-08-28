# = Class: motd
#
# This class configures a sensible motd
#
# == Sample Usage:
#
#   include motd
#
class motd {
	file { '/etc/motd.tail':
		ensure => absent,
	}

	if versioncmp($::lsbmajdistrelease, '9') < 0 {
		file { '/etc/motd':
			ensure => link,
			target => '/var/run/motd'
		}
		file { '/etc/update-motd.d':
			ensure => directory,
			mode   => '0755'
		}
		file { '/etc/update-motd.d/puppet-motd':
			notify  => undef,
			mode    => '0555',
			content => template('motd/motd.erb')
		}
	} else {
		file { '/etc/update-motd.d/puppet-motd':
			ensure => absent,
		}
		file { '/etc/motd':
			notify  => undef,
			content => template('motd/motd.erb')
		}
	}
}
