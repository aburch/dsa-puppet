#
class salsa::packages inherits salsa {
	$requirements = [
		'build-essential',
		'bundler',
		'checkinstall',
		'cmake',
		'curl',
		'golang',
		'libcurl4-openssl-dev',
		'libffi-dev',
		'libgdbm-dev',
		'libicu-dev',
		'libncurses5-dev',
		'libre2-dev',
		'libreadline-dev',
		'libssl-dev',
		'libxml2-dev',
		'libxslt1-dev',
		'libyaml-dev',
		'logrotate',
		'node-mkdirp',
		'node-semver',
		'nodejs',
		'nodejs-legacy',
		'pkg-config',
		'python-docutils',
		'libpq-dev',
		'zlib1g-dev'
	]

	ensure_packages($requirements, { ensure => 'installed' })

#	file { "${salsa::home}/yarn":
#		ensure => directory,
#		owner  => $salsa::user,
#		group  => $salsa::group,
#		mode   => '0755',
#	}

#	archive { "yarn-${gitlab::yarnversion}.tar.gz":
#		path         => "${gitlab::home}/yarn-${gitlab::yarnversion}.tar.gz",
#		source       => "https://github.com/yarnpkg/yarn/releases/download/${gitlab::yarnversion}/yarn-${gitlab::yarnversionett}.tar.gz",
#		extract      => true,
#		extract_path => "${gitlab::params::home}/yarn",
#		cleanup      => true,
#		user         => $gitlab::user,
#		group        => $gitlab::group,
#		require      => File["${gitlab::home}/yarn"],
#	}
#	
#	if $gitlab::source_manage {
#		vcsrepo { "${gitlab::home}/gitlab":
#			ensure   => present,
#			provider => git,
#			source   => 'https://github.com/gitlabhq/gitlabhq.git',
#			revision => $gitlab::source_version,
#			owner => $gitlab::user, 
#			group => $gitlab::group
#		}
#	}
}
