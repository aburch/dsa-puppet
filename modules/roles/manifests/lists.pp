class roles::lists {
	ssl::service { 'lists.debian.org':
		notify  => Exec['service apache2 reload'],
		key => true,
	}
}
