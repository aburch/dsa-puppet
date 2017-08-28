class hardware::raid::proliant {
	if $::smartarraycontroller_hpsa or $::smartarraycontroller_cciss {
		site::aptrepo { 'debian.restricted':
			url        => 'http://db.debian.org/debian-admin',
			suite      => "${::lsbdistcodename}-restricted",
			components => 'non-free',
		}

		package { 'hpacucli':
			ensure  => installed,
			tag    => extra_repo,
		}
		package { 'hpssacli':
			ensure  => installed,
			tag    => extra_repo,
		}
		if !("$::systemproductname" in ["ProLiant DL180 G5", "ProLiant DL120 G5", "ProLiant ML150 G5"]) {
			package { 'hp-health':
				ensure => installed,
				tag    => extra_repo,
			}
		}

		if $::debarchitecture == 'amd64' {
			package { 'lib32gcc1':
				ensure => installed,
			}
		}

		if $::smartarraycontroller_hpsa {
			concat::fragment { 'dsa-check-hpssacli':
				target => '/etc/cron.d/puppet-nagios-wraps',
				order  => '020',
				content  => @(EOF)
					27 * * * * root sleep $(( $RANDOM \% 900 )); dsa-wrap-nagios-check dsa-check-hpssacli
					| EOF
			}
		}
		file { '/etc/cron.d/puppet-nagios-hpsa':
			ensure => absent,
		}
	} else {
		site::aptrepo { 'debian.restricted':
			ensure => absent,
		}
	}
}
