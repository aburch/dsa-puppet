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
}
