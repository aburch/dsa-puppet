#
class salsa::params {
	$user = "git"
	$group = "git"
	$home = "/srv/salsa.debian.org"

	$db_name = "salsa"
	$db_role = "salsa"
	$db_password = hkdf('/etc/puppet/secret', "postgresql-${::hostname}-salsa-${db_role}")

	$mail_username = "gitlab"
	$mail_password = hkdf('/etc/puppet/secret', "mail-imap-dovecot-${::hostname}-salsa-${mail_username}")
}
