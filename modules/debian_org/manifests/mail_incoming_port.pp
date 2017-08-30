class debian_org::mail_incoming_port {
	case getfromhash($site::nodeinfo, 'mail_port') {
		Numeric: { $mail_port = sprintf("%d", getfromhash($site::nodeinfo, 'mail_port')) }
		/^(\d+)$/: { $mail_port = $1 }
		default: { $mail_port = '25' }
	}

	@ferm::rule { 'dsa-mail':
		description => 'Allow SMTP',
		rule        => "&SERVICE_RANGE(tcp, $mail_port, \$SMTP_SOURCES)"
	}

	@ferm::rule { 'dsa-mail-v6':
		description => 'Allow SMTP',
		domain      => 'ip6',
		rule        => "&SERVICE_RANGE(tcp, $mail_port, \$SMTP_V6_SOURCES)"
	}
	dnsextras::tlsa_record{ 'tlsa-mailport':
		zone     => 'debian.org',
		certfile => "/etc/puppet/modules/exim/files/certs/${::fqdn}.crt",
		port     => $mail_port,
		hostname => $::fqdn,
	}
}
