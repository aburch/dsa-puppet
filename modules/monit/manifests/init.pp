# = Class: monit
#
# This class installs and configures monit
#
# == Sample Usage:
#
#   include monit
#
class monit {
	if versioncmp($::lsbmajdistrelease, '7') <= 0 {
		package { 'monit':
			ensure => installed
		}

		augeas { 'inittab_monit':
			context => '/files/etc/inittab',
			changes => [
				'set mo/runlevels 2345',
				'set mo/action respawn',
				"set mo/process \"/usr/bin/monit -d 300 -I -c /etc/monit/monitrc -s /var/lib/monit/monit.state\"",
			],
			notify => Exec['init q'],
		}

		file { '/etc/monit/':
			ensure  => directory,
			mode    => '0755',
			purge   => true,
			notify  => Exec['service monit stop'],
			require => Package['monit'],
		}
		file { '/etc/monit/monit.d':
			ensure  => directory,
			mode    => '0750',
			purge   => true,
		}
		file { '/etc/monit/monitrc':
			content => template('monit/monitrc.erb'),
			mode    => '0400'
		}
		file { '/etc/monit/monit.d/01puppet':
			source  => 'puppet:///modules/monit/puppet',
			mode    => '0440'
		}
		file { '/etc/monit/monit.d/00debian.org':
			source  => 'puppet:///modules/monit/debianorg',
			mode    => '0440'
		}
		file { '/etc/default/monit':
			content => template('monit/default.erb'),
			require => Package['monit'],
			notify  => Exec['service monit stop']
		}

		exec { 'service monit stop':
			refreshonly => true,
		}
	} else {
		package { 'monit':
			ensure => purged
		}
		file { [ '/etc/monit/',
		         '/etc/monit/monit.d',
		         '/etc/monit/monit.d/01puppet',
		         '/etc/monit/monit.d/00debian.org'
			]:
			ensure  => absent,
			force   => true
		}
	}
}
