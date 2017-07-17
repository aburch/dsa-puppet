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
					notify  => Exec['systemctl daemon-reload'],
				}
			} elsif $source {
				file { "${dest}":
					ensure  => $ensure,
					source  => $source,
					notify  => Exec['systemctl daemon-reload'],
				}
			}
		}
		absent:  {
			file { "${dest}":
				ensure  => $ensure,
				notify  => Exec['service apache2 reload'],
			}
			file { "${dir}":
				ensure => $ensure
			}
		}
		default: { fail ( "Unknown ensure value: '$ensure'" ) }
	}
}
