Facter.add("keyring_debian_org_mirror") do
	setcode do
		FileTest.exist?("/srv/keyring.debian.org") and
		File.stat("/srv/keyring.debian.org").uid == 0 and
		FileTest.exist?("/var/lib/misc/thishost/debian-keyring.gpg")
	end
end
