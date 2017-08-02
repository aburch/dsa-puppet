class hardware {
	include hardware::raid

	if "$::systemproductname" in ["ProLiant DL385 G1", "ProLiant DL380 G4", "ProLiant DL360 G4"] {
		file { '/etc/apt/preferences.d/dsa-hp-tools':
			content => "Package: hp-health\nPin: version 8.6*\nPin-Priority: 1100\n"
		}
	#} elsif "$::systemproductname" in ["ProLiant DL380 G5", "ProLiant DL360 G5", "ProLiant DL380 G6", "ProLiant DL360 G6", "ProLiant BL495c G5"] {
	#	file { '/etc/apt/preferences.d/dsa-hp-tools':
	#		content => "Package: hp-health\nPin: version 10.0.*\nPin-Priority: 1100\n"
	#	}
	} else {
		file { '/etc/apt/preferences.d/dsa-hp-tools':
			ensure => absent
		}
	}

	include hardware::sensors
}
