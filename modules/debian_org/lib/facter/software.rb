Facter.add("apache2") do
	setcode do
		if FileTest.exist?("/usr/sbin/apache2")
			true
		else
			false
		end
	end
end
Facter.add("apache2deb9") do
	setcode do
		# jessie (deb8) has 2.4.10-.., stretch (deb9) will have 2.4.23 or later.
		if FileTest.exist?("/usr/sbin/apache2") and system("dpkg --compare-versions $(dpkg-query -W -f='${Version}\n' apache2-bin) gt 2.4.15")
			true
		else
			false
		end
	end
end
Facter.add("clamd") do
	setcode do
		if FileTest.exist?("/usr/sbin/clamd")
			true
		else
			false
		end
	end
end
Facter.add("exim4") do
	setcode do
		if FileTest.exist?("/usr/sbin/exim4")
			true
		else
			false
		end
	end
end
Facter.add("postfix") do
	setcode do
		if FileTest.exist?("/usr/sbin/postfix")
			true
		else
			false
		end
	end
end
Facter.add("postgres") do
	setcode do
		pg = (FileTest.exist?("/usr/lib/postgresql/9.1/bin/postgres") or
		FileTest.exist?("/usr/lib/postgresql/9.4/bin/postgres") or
		FileTest.exist?("/usr/lib/postgresql/9.6/bin/postgres"))
		if pg
			true
		else
			false
		end
	end
end
Facter.add("postgrey") do
	setcode do
		if FileTest.exist?("/usr/sbin/postgrey")
			true
		else
			false
		end
	end
end
Facter.add("greylistd") do
	setcode do
		FileTest.exist?("/usr/sbin/greylistd")
	end
end
Facter.add("policydweight") do
	setcode do
		if FileTest.exist?("/usr/sbin/policyd-weight")
			true
		else
			false
		end
	end
end
Facter.add("spamd") do
	setcode do
		if FileTest.exist?("/usr/sbin/spamd")
			true
		else
			false
		end
	end
end
Facter.add("php5") do
	php =   (FileTest.exist?("/usr/lib/apache2/modules/libphp5.so") or
		FileTest.exist?("/usr/bin/php5") or
		FileTest.exist?("/usr/bin/php5-cgi") or
		FileTest.exist?("/usr/lib/cgi-bin/php5"))
	setcode do
		if php
			true
		else
			false
		end
	end
end
Facter.add("php5suhosin") do
	suhosin=(FileTest.exist?("/usr/lib/php5/20060613/suhosin.so") or
		FileTest.exist?("/usr/lib/php5/20060613+lfs/suhosin.so"))
	setcode do
		if suhosin
			true
		else
			false
		end
	end
end
Facter.add("syslogversion") do
	setcode do
		%x{dpkg-query -W -f='${Version}\n' syslog-ng | cut -b1-3}.chomp
	end
end
Facter.add("unbound") do
	unbound=(FileTest.exist?("/usr/sbin/unbound") and
		FileTest.exist?("/var/lib/unbound/root.key"))
	setcode do
		if unbound
			true
		else
			false
		end
	end
end
Facter.add("munin_async") do
	setcode do
		FileTest.exist?("/usr/share/munin/munin-async")
	end
end
Facter.add("samhain") do
	setcode do
		if FileTest.exist?("/usr/sbin/samhain")
			true
		else
			false
		end
	end
end
Facter.add("systemd") do
	setcode do
		init = '/sbin/init'
		if File.symlink?(init) and File.readlink(init) == "/lib/systemd/systemd"
			true
		else
			false
		end
	end
end
Facter.add("tor_ge_0_2_9") do
	setcode do
		system(%{test -n "$(dpkg-query -W -f='${Version}' tor)" && dpkg --compare-versions "$(dpkg-query -W -f='${Version}' tor)" ge 0.2.9})
	end
end
