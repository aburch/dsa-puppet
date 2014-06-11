class hardware {
	include hardware::raid

	if "$::systemproductname" in ["ProLiant BL495c G5", "ProLiant DL385 G1", "ProLiant DL380 G4", "ProLiant DL360 G4"] {
		file { '/etc/apt/preferences.d/dsa-hp-tools':
			content => "Package: hp-health\nPin: version 8.6*\nPin-Priority: 1100\n"
		}
	}

	include hardware::sensors
}
