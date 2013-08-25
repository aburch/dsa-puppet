class roles::pubsub {
	include roles::pubsub::params

	$cluster_cookie = $roles::pubsub::params::cluster_cookie
	$admin_password = $roles::pubsub::params::admin_password
	$cc_master      = rainier
	$cc_secondary   = rapoport

	class { 'rabbitmq':
		cluster           => true,
		clustermembers    => [
			"rabbit@${cc_master}",
			"rabbit@${cc_secondary}",
		],
		clustercookie     => '8r17so6o1s124ns49sr08n0o24342160',
		delete_guest_user => true,
		master            => $cc_master,
	}

	rabbitmq_user { 'admin':
		admin    => true,
		password => $admin_password,
		provider => 'rabbitmqctl',
	}

	rabbitmq_vhost { 'packages':
		ensure   => present,
		provider => 'rabbitmqctl',
	}

	rabbitmq_user_permissions { 'admin@packages':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => [
			Rabbitmq_user['admin'],
			Rabbitmq_vhost['packages']
		]
	}

	rabbitmq_user_permissions { 'admin@/':
		configure_permission => '.*',
		read_permission      => '.*',
		write_permission     => '.*',
		provider             => 'rabbitmqctl',
		require              => Rabbitmq_user['admin']
	}
}
