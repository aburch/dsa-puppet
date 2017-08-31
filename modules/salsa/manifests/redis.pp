#
class salsa::redis inherits salsa {
	ensure_packages ( "redis-server", { ensure => 'installed' })

	service { 'redis-server':
		ensure  => 'running',
		enable  => true,
		require => Package['redis-server'],
	}

	file { "/etc/redis/redis.conf":
		mode => "640",
		owner => redis,
		group => redis,
		source => "puppet:///modules/salsa/redis.conf",
		notify  => Service['redis-server'],
		require => Package['redis-server'],
	} 

	file { "/var/run/redis":
		ensure => "directory",
		mode => "750",
		owner => redis,
		group => redis,
		notify  => Service['redis-server'],
	}
}
