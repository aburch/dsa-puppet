#
class postgres {
	$ensure = ($::postgres) ? {
		true    => 'present',
		default => 'absent'
	}

	munin::check { 'postgres_bgwriter':
		ensure => $ensure,
		}
	munin::check { 'postgres_connections_db':
		ensure => $ensure,
		}
	munin::check { 'postgres_cache_ALL':
		ensure => $ensure,
		script => 'postgres_cache_'
	}
	munin::check { 'postgres_querylength_ALL':
		ensure => $ensure,
		script => 'postgres_querylength_'
	}
	munin::check { 'postgres_size_ALL':
		ensure => $ensure,
		script => 'postgres_size_'
	}

	file { '/etc/munin/plugin-conf.d/local-postgres':
		ensure => $ensure,
		source  => 'puppet:///modules/postgres/plugin.conf',
	}
}
