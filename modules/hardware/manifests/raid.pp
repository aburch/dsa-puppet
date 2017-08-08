class hardware::raid {
	include hardware::raid::proliant

	if $::productname == 'PowerEdge 1950' {
		include hardware::raid::dell
	}

	include hardware::raid::raidmpt
}
