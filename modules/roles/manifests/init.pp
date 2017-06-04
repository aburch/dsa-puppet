# = Class: roles
#
# Lookup role and include relevant classes for roles
#
# == Sample Usage:
#
#   include roles
#
class roles {

	if has_role('puppetmaster') {
		include puppetmaster
	}

	if has_role('muninmaster') {
		include munin::master
	}

	if has_role('nagiosmaster') {
	#	include nagios::server
		ssl::service { 'nagios.debian.org':
			notify  => Exec['service apache2 reload'],
			key => true,
		}
	}

	# XXX: turn this into a real role
	if getfromhash($site::nodeinfo, 'buildd') {
		include buildd
	}

	# XXX: turn this into a real role
	if getfromhash($site::nodeinfo, 'porterbox') {
		include porterbox
	}

	if has_role('bugs_mirror') {
		include roles::bugs_mirror
	}

	if has_role('bugs_base') {
		ssl::service { 'bugs.debian.org':
			notify  => Exec['service apache2 reload'],
			key => true,
		}
	}
	if has_role('bugs_master') {
		ssl::service { 'bugs-master.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('manpages-dyn') {
		include roles::manpages_dyn
	}

	if has_role('archvsync_base_additional') {
		include archvsync_base
	}

	# archive.debian.org
	if has_role('historical_mirror') {
		include roles::historical_mirror
	}

	# debug archive
	if has_role('debug_mirror') {
		include roles::debug_mirror
	}

	# ftp.debian.org and its ecosystem
	if has_role('debian_mirror') {
		include roles::debian_mirror
	}
	if has_role('ftp.d.o') {
		include roles::ftp
	}
	if has_role('ftp_master') {
		include roles::ftp_master
		include roles::dakmaster
	}
	if has_role('ftp.upload.d.o') {
		include roles::ftp_upload
	}
	if has_role('ssh.upload.d.o') {
		include roles::ssh_upload
	}
	if has_role('api.ftp-master') {
		ssl::service { 'api.ftp-master.debian.org':
			notify  => Exec['service apache2 reload'],
			key => true,
		}
	}
	#
	# security.debian.org
	if has_role('security_master') {
		include roles::security_master
		include roles::dakmaster
	}
	if has_role('security_mirror') {
		include roles::security_mirror
	}

	if has_role('git_master') {
		include roles::git_master
	}

	if has_role('people') {
		ssl::service { 'people.debian.org': notify  => Exec['service apache2 reload'], key => true, }
		onion::service { 'people.debian.org': port => 80, target_address => 'people.debian.org', target_port => 80, direct => true }
	}

	if has_role('www_master') {
		include roles::www_master
	}

	if has_role('cgi.d.o') {
		ssl::service { 'cgi.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('keyring') {
		include roles::keyring
	}

	if has_role('wiki') {
		include roles::wiki
	}

	if has_role('syncproxy') {
		include roles::syncproxy
	}

	if has_role('static_master') {
		include roles::static_master
	}

	if has_role('static_mirror') {
		include roles::static_mirror
	} elsif has_role('static_source') {
		include roles::static_source
	}

	if has_role('weblog_provider') {
		include roles::weblog_provider
	}

	if has_role('mailrelay') {
		include roles::mailrelay
	}

	if has_role('pubsub') {
		include roles::pubsub
	}

	if has_role('dbmaster') {
		include roles::dbmaster
	}

	if has_role('dns_primary') {
		include named::primary
	}

	if has_role('weblog_destination') {
		include roles::weblog_destination
	}

	if has_role('vote') {
		include roles::vote
	}

	if has_role('security_tracker') {
		include roles::security_tracker
	}

	if has_role('lists') {
		include roles::lists
	}

	if has_role('list_search') {
		include roles::listsearch
	}

	if has_role('rtmaster') {
		include roles::rtmaster
	}

	if has_role('udd') {
		include roles::udd
	}

	if has_role('sso') {
		include roles::sso
	}

	if has_role('sso_rp') {
		include roles::sso_rp
	}

	if has_role('tracker') {
		include roles::tracker
	}

	if has_role('buildd_master') {
		include roles::buildd_master
	}

	if has_role('piuparts') {
		include roles::piuparts
	}
	if has_role('piuparts_slave') {
		include roles::piuparts_slave
	}

	if has_role('contributors') {
		include roles::contributors
	}

	if has_role('nm') {
		include roles::nm
	}

	if has_role('rtc') {
		include roles::rtc
	}

	if has_role('jenkins') {
		include roles::jenkins
	}

	if has_role('keystone') {
		include roles::keystone
	}
	if has_role('keystone_rabbitmq') {
		include roles::keystone::rabbitmq
	}

	if has_role('memcached') {
		include roles::memcached
	}

	if has_role('postgres_backup_server') {
		include postgres::backup_server
	}

	if has_role('packages') {
		ssl::service { 'packages.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('historicalpackages') {
		ssl::service { 'historical.packages.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('qamaster') {
		ssl::service { 'qa.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('packagesqamaster') {
		ssl::service { 'packages.qa.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('gobby_debian_org') {
		ssl::service { 'gobby.debian.org': notify  => Exec['service apache2 reload'], key => true, tlsaport => [443, 6523], }
	}

	if has_role('search_backend') {
		include roles::search_backend
	}
	if has_role('search_frontend') {
		include roles::search_frontend
	}

	if has_role('dgit_browse') {
		include roles::dgit_browse
	}
	if has_role('dgit_git') {
		include roles::dgit_git
	}

	if $::hostname in [lw01, lw02, lw03, lw04] {
		include roles::snapshot
	}

	if has_role('veyepar.debian.org') {
		ssl::service { 'veyepar.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}
	if has_role('sreview.debian.org') {
		ssl::service { 'sreview.debian.net': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('debtags') {
		include roles::debtags
	}

	if has_role('planet_search') {
		ssl::service { 'planet-search.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('i18n.d.o') {
		ssl::service { 'i18n.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('l10n.d.o') {
		ssl::service { 'l10n.debian.org': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('dedup.d.n') {
		ssl::service { 'dedup.debian.net': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('pet.d.n') {
		ssl::service { 'pet.debian.net': notify  => Exec['service apache2 reload'], key => true, }
		ssl::service { 'pet-devel.debian.net': notify  => Exec['service apache2 reload'], key => true, }
	}

	if has_role('ports_master') {
		include roles::ports_master
	}
	if has_role('ports_mirror') {
		include roles::ports_mirror
	}

	if has_role('onionbalance') {
		include onion::balance
	}
	if has_role('bgp') {
		include roles::bgp
	}
	if has_role('cdimage-search') {
		include roles::cdimage_search
	}

	if has_role('postgresql_server') {
		include roles::postgresql_server
	}

	if has_role('bacula_director') {
		include bacula::director
	} else {
		package { 'bacula-console': ensure => purged; }
		file { '/etc/bacula/bconsole.conf': ensure => absent; }
	}
	if has_role('bacula_storage') {
		include bacula::storage
	}
}
