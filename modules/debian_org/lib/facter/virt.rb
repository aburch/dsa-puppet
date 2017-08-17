Facter.add("virt") do
	setcode do
		begin
			`systemd-detect-virt`.chomp()
		rescue Errno::ENOENT
			nil
		end
	end
end
p
