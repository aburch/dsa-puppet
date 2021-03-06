require 'puppet/file_system'

module Puppet::Parser::Functions
  newfunction(:whohosts, :type => :rvalue) do |args|
    require 'ipaddr'
    require 'yaml'

    ipAddrs = args[0]

    ans = {"name" => "unknown"}
    yamlfile = Puppet::Parser::Files.find_file('debian_org/misc/hoster.yaml', compiler.environment)
    yaml = YAML.load_file(yamlfile)

    ipAddrs.each do |addr|
      yaml.keys.each do |hoster|
        next unless yaml[hoster].kind_of?(Hash) and yaml[hoster].has_key?('netrange')
        netrange = yaml[hoster]['netrange']

        netrange.each do |net|
          begin
            if IPAddr.new(net).include?(addr)
              ans = yaml[hoster]
              ans['name'] = hoster
            end
          rescue => e
            raise Puppet::ParseError, "Error while trying to match addr #{addr} for net #{net}: #{e.message}\n#{e.backtrace}"
          end
        end
      end
    end
    if not ans['longname']
      ans['longname'] = ans['name']
    end
    return ans
  end
end
# vim:set ts=2:
# vim:set et:
# vim:set shiftwidth=2:
