module Puppet::Parser::Functions
  newfunction(:nodeinfo, :type => :rvalue) do |args|

    host = args[0]
    yamlfile = args[1]
    parser.watch_file(yamlfile)

    require 'yaml'
    require '/etc/puppet/lib/puppet/parser/functions/ldapinfo.rb'

    $KCODE = 'utf-8'

    yaml = YAML.load_file(yamlfile)
    results = {}

    ['nameinfo', 'footer'].each do |detail|
      if yaml.has_key?(detail)
        if yaml[detail].has_key?(host)
          results[detail] = yaml[detail][host]
        end
      end
    end

    if yaml.has_key?('services')
      yaml['services'].each_pair do |service, hostlist|
        hostlist=[hostlist] unless hostlist.kind_of?(Array)
        results[service] = hostlist.include?(host)
      end
    end

    results['mail_port']      = ''
    results['smarthost']      = ''
    results['heavy_exim']     = ''
    results['smarthost_port'] = 587
    results['reservedaddrs']  = '0.0.0.0/8 : 127.0.0.0/8 : 10.0.0.0/8 : 169.254.0.0/16 : 172.16.0.0/12 : 192.0.0.0/17 : 192.168.0.0/16 : 224.0.0.0/4 : 240.0.0.0/5 : 248.0.0.0/5'

    if yaml['host_settings'].kind_of?(Hash)
      yaml['host_settings'].each_pair do |property, values|
        if values.kind_of?(Hash)
          results[property] = values[host] if values.has_key?(host)
        elsif values.kind_of?(Array)
          results[property] = "true" if values.include?(host)
        end
      end
    end

    results['ldap'] = function_ldapinfo(host, '*')
    return(results)
  end
end

# vim: set fdm=marker ts=2 sw=2 et:
