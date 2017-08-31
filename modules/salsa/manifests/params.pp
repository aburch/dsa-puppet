#
class salsa::params {
	$user = "git"
	$group = "git"
	$home = "/srv/salsa.debian.org"

	# $salsa_   = hkdf('/etc/puppet/secret', "bacula-dir-${::hostname}")
}
