class buildd ($ensure=present) {
	# Do nothing until we get the buildd user from ldap
	if $::buildd_user_exists {
		include schroot

		package { 'sbuild':
			ensure => installed,
			tag    => extra_repo,
		}
		package { 'libsbuild-perl':
			ensure => installed,
			tag    => extra_repo,
			before => Package['sbuild']
		}

		package { 'apt-transport-https':
			ensure => installed,
		}
		if $ensure == present {
			package { 'dupload':
				ensure => installed,
			}
			file { '/etc/dupload.conf':
				source  => 'puppet:///modules/buildd/dupload.conf',
				require => Package['dupload'],
			}
			package { 'buildd':
				ensure => installed,
			}
			file { '/etc/buildd/buildd.conf':
				source  => 'puppet:///modules/buildd/buildd.conf',
				require => Package['buildd'],
			}
			file { '/etc/sbuild/sbuild.conf':
				source  => 'puppet:///modules/buildd/sbuild.conf',
				require => Package['sbuild'],
			}
			include ferm::ftp_conntrack
		}

		site::aptrepo { 'buildd':
			ensure => absent,
		}

		$suite = $::lsbdistcodename ? {
			wheezy   => $::lsbdistcodename,
			jessie   => $::lsbdistcodename,
			stretch  => $::lsbdistcodename,
			undef   => 'wheezy',
			default => 'jessie'
		}

		if (versioncmp($::lsbmajdistrelease, '9') >= 0) {
			site::aptrepo { 'buildd.debian.org':
				ensure => absent,
			}
		} else {
			site::aptrepo { 'buildd.debian.org':
				key        => 'puppet:///modules/buildd/buildd.debian.org.gpg',
				url        => 'https://apt.buildd.debian.org/',
				suite      => $suite,
				components => 'main',
				require    => Package['apt-transport-https'],
			}
		}

		file { '/etc/apt/apt.conf.d/puppet-https-buildd':
			content => "Acquire::https::apt.buildd.debian.org::CaInfo \"/etc/ssl/ca-debian/ca-certificates.crt\";\n",
		}

		# 'bad' extension
		file { '/etc/apt/preferences.d/buildd.debian.org':
			ensure => absent,
		}
		file { '/etc/apt/preferences.d/buildd':
			ensure => absent,
		}
		file { '/etc/cron.d/dsa-buildd':
			source  => 'puppet:///modules/buildd/cron.d-dsa-buildd',
			require => Package['debian.org']
		}

		if ($::kernel == 'Linux') {
			package { 'python-psutil':
				ensure => installed,
			}
			file { '/usr/local/sbin/buildd-schroot-aptitude-kill':
				source  => 'puppet:///modules/buildd/buildd-schroot-aptitude-kill',
				mode    => '0555',
			}
		} else {
			file { '/usr/local/sbin/buildd-schroot-aptitude-kill':
				source  => 'puppet:///modules/buildd/buildd-schroot-aptitude-kill.squeeze',
				mode    => '0555',
			}
		}
		file { '/etc/cron.d/puppet-buildd-aptitude':
			content => "*/5 * * * * root /usr/local/sbin/buildd-schroot-aptitude-kill\n",
		}

		service { 'buildd':
			enable => false,
			ensure => 'stopped',
		}

		if $has_srv_buildd {
			file { '/etc/cron.d/puppet-update-buildd-schroots':
				content  => "13 21 * * 0,3 root PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin setup-all-dchroots buildd\n",
			}
		}

		file { '/home/buildd':
			ensure  => directory,
			mode    => '2755',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/build':
			ensure  => directory,
			mode    => '2750',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/logs':
			ensure  => directory,
			mode    => '2750',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/old-logs':
			ensure  => directory,
			mode    => '2750',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/upload-security':
			ensure  => directory,
			mode    => '2750',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/stats':
			ensure  => directory,
			mode    => '2755',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/stats/graphs':
			ensure  => directory,
			mode    => '2755',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/upload':
			ensure  => directory,
			mode    => '2755',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/.forward':
			content  => "|/usr/bin/buildd-mail\n",
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/.gnupg':
			ensure  => directory,
			mode    => '700',
			group   => buildd,
			owner   => buildd,
		}
		file { '/home/buildd/.gnupg/gpg.conf':
			content  => "personal-digest-preferences SHA512\n",
			group   => buildd,
			owner   => buildd,
		}

		if ! $::buildd_key {
			exec { 'create-buildd-key':
				command => '/bin/su - buildd -c \'mkdir -p -m 02700 .ssh && ssh-keygen -C "`whoami`@`hostname` (`date +%Y-%m-%d`)" -P "" -f .ssh/id_rsa -q\'',
				onlyif  => '/usr/bin/getent passwd buildd > /dev/null && ! [ -e /home/buildd/.ssh/id_rsa ]'
			}
		}


		exec { 'add-buildd-user-to-sbuild':
			command => 'adduser buildd sbuild',
			onlyif  => "getent group sbuild > /dev/null && ! getent group sbuild | grep '\\<buildd\\>' > /dev/null"
		}
	}
}
