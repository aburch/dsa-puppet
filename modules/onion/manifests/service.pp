define onion::service (
	$port,
	$target_address,
	$target_port
) {
	include onion

	concat::fragment { "onion::torrc_onionservice::${name}":
		target  => "/etc/tor/torrc",
		order   => 10,
		content => "HiddenServiceDir /var/lib/tor/onion/${name}\nHiddenServicePort ${port} ${target_address}:${target_port}\n\n",
	}

	$onion_hn = onion_hostname($name)
	if $onion_hn {
		@@concat::fragment { "onion::balance::instance::$name::$hostname":
			target  => "/etc/onionbalance/config",
			content => "      - address: ${onion_hn}\n        name: ${hostname}-${name}",
			tag => "onion::balance::$name",
		}
	}
}
