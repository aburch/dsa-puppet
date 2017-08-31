#
class salsa::params {
	$servicename = "salsa.debian.org"

	$user = "git"
	$group = "git"
	$home = "/srv/${servicename}}"

	$db_name = "salsa"
	$db_role = "salsa"
	$db_password = hkdf('/etc/puppet/secret', "postgresql-${::hostname}-${servicename}-${db_role}")

	$mail_username = "gitlab@${servicename}"
	$mail_password = hkdf('/etc/puppet/secret', "mail-imap-dovecot-${::hostname}-${servicename}-${mail_username}")
}
