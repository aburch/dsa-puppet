#
class salsa inherits salsa::params {

	# anchor things in correct order
	anchor { 'salsa::begin': } ->
	class { '::salsa::mail': } ->
	class { '::salsa::redis': } ->
	class { '::salsa::packages': } ->
	class { '::salsa::database': } ->
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

	file { "${salsa::home}/.credentials.yaml":
		mode => '0400',
		owner  => $salsa::user,
		group  => $salsa::group,
		content  => @("EOF"),
				---
				database:
				  name: "${salsa::db_name}"
				  role: "${salsa::db_role}"
				  password: "${salsa::db_password}"
				mail:
				  username: "${salsa::mail_username}"
				  password: "${salsa::mail_password}"
				| EOF
	}
}
