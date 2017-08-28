Facter.add("smartarraycontroller") do
	confine :kernel => :linux
	setcode do
		if FileTest.exist?("/dev/cciss/")
			true
		elsif FileTest.exist?("/sys/module/hpsa/")
			true
		else
			false
		end
	end
end

Facter.add("smartarraycontroller_cciss") do
	confine :kernel => :linux
	setcode do
		FileTest.exist?("/dev/cciss/")
	end
end

Facter.add("smartarraycontroller_hpsa") do
	confine :kernel => :linux
	setcode do
		FileTest.exist?("/sys/module/hpsa/")
	end
end


Facter.add("ThreeWarecontroller") do
	confine :kernel => :linux
	setcode do
		is3w = false
		if FileTest.exist?("/proc/scsi/scsi")
			IO.foreach("/proc/scsi/scsi") { |x|
				is3w = true if x =~ /Vendor: 3ware/
			}
		end
		is3w
	end
end

Facter.add("megaraid") do
	confine :kernel => :linux
	setcode do
		if FileTest.exist?("/dev/megadev0")
			true
		else
			false
		end
	end
end

Facter.add("mptraid") do
	confine :kernel => :linux
	setcode do
		if FileTest.exist?("/dev/mptctl") or FileTest.exist?("/dev/mpt0") or FileTest.exist?("/proc/mpt/summary")
			true
		else
			false
		end
	end
end

Facter.add("aacraid") do
	confine :kernel => :linux
	setcode do
		if FileTest.exist?("/dev/aac0")
			true
		else
			false
		end
	end
end

Facter.add("swraid") do
	confine :kernel => :linux
	setcode do
                swraid = false
		if FileTest.exist?("/proc/mdstat") && FileTest.exist?("/sbin/mdadm")
                        IO.foreach("/proc/mdstat") { |x|
                                swraid = true if x =~ /md[0-9]+ : active/
                        }
                end
                swraid
	end
end

