#
class salsa (
	$user = $salsa::params::user,
	$group = $salsa::params::group,
	$home = $salsa::params::home,
) inherits salsa::params {

	# anchor things in correct order
	anchor { 'salsa::begin': } ->
	class { '::salsa::mail': } ->
	class { '::salsa::redis': } ->
	class { '::salsa::packages': } ->
	anchor { 'salsa::end': }

	# userdir-ldap users get their home in /home
	file { "/home/${salsa::user}":
		ensure => link,
		target => $salsa::home,
	}
	file { $salsa::home:
		ensure => directory,
		mode   => '0755',
		owner  => $salsa::user,
		group  => $salsa::group,
	}
}
