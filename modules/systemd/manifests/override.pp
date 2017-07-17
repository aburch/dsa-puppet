define systemd::override (
	$source=undef,
	$content=undef,
	$ensure=present
) {

	$dir = "/etc/systemd/system/${name}.service.d"
	$dest = "${dir}/override.conf"
	case $ensure {
		present: {
			if ! ($source or $content) {
				fail ( "No configuration found for ${name}" )
			}

			file { "${dir}":
				ensure => directory,
				mode   => '0755'
			}
			if $content {
				file { "${dest}":
					ensure  => $ensure,
					content => $content,
					notify  => [ Exec['systemctl daemon-reload'],
					             Service["${name}"],
					            ]
				}
			} elsif $source {
				file { "${dest}":
					ensure  => $ensure,
					source  => $source,
					notify  => [ Exec['systemctl daemon-reload'],
					             Service["${name}"],
					           ]
					}
			}
		}
		absent:  {
			if defined(Service["${name}"]) {
				$notify = [ Exec['systemctl daemon-reload'], Service["${name}"] ]
			} else {
				$notify = [ Exec['systemctl daemon-reload'] ]
			}

			file { "${dest}":
				ensure  => $ensure,
				notify  => $notify,
			}
			file { "${dir}":
				ensure => $ensure
			}
		}
		default: { fail ( "Unknown ensure value: '$ensure'" ) }
	}
}
