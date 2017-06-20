class ferm::aql {
	@ferm::rule { 'dsa-drop-multicast':
		domain      => 'ip',
		description => 'drop multicast traffic to avoid triggering protection',
		table       => 'filter',
		chain       => 'OUTPUT',
		rule        => 'destination 224.0.0.0/4 jump log_or_drop'
	}
}

