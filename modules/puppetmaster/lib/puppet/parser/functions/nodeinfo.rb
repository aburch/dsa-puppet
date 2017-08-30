module Puppet::Parser::Functions
  newfunction(:nodeinfo, :type => :rvalue) do |args|
    host = args[0]
    yamlfile = args[1]
    begin
      nodeinfo         = function_yamlinfo([host, yamlfile])
      nodeinfo['ldap'] = function_ldapinfo([host, '*'])
      unless nodeinfo['ldap']['ipHostNumber']
        raise Puppet::ParseError, "Host #{host} does not have ipHostNumber values in ldap"
      end
      nodeinfo['hoster'] = function_whohosts([nodeinfo['ldap']['ipHostNumber']])
      nodeinfo['buildd'] = (nodeinfo['ldap']['purpose'].respond_to?('include?') && nodeinfo['ldap']['purpose'].include?('buildd'))
      nodeinfo['timeserver'] = (nodeinfo['ldap']['purpose'].respond_to?('include?') && nodeinfo['ldap']['purpose'].include?('timeserver'))
      nodeinfo['porterbox'] = (nodeinfo['ldap']['purpose'].respond_to?('include?') && nodeinfo['ldap']['purpose'].include?('porterbox'))

      if lookupvar('::mta') == 'exim4'
        unless nodeinfo['heavy_exim']
          nodeinfo['smarthost'] = 'mailout.debian.org'
        end
      elsif lookupvar('::mta') == 'postfix'
        unless nodeinfo['heavy_postfix']
          nodeinfo['smarthost'] = 'mailout.debian.org'
        end
      end

      nodeinfo['misc'] = {}
      fqdn = lookupvar('::fqdn')
      if fqdn and fqdn == host
        v4ips = lookupvar('::v4ips')
        if v4ips and v4ips.to_s != "" and v4ips.to_s != 'undefined'
          nodeinfo['misc']['v4addrs'] = v4ips.split(',')

          # find out if we are behind nat
          intersection = nodeinfo['misc']['v4addrs'] & nodeinfo['ldap']['ipHostNumber']
          nodeinfo['misc']['natted'] = intersection.empty?
        end

        v6ips = lookupvar('::v6ips')
        if v6ips and v6ips.to_s != "" and v6ips.to_s != 'undefined'
          nodeinfo['misc']['v6addrs'] = v6ips.split(',')
        end
      end

      ns = call_function('hiera',['nameservers'])
      allow_dns_q = call_function('hiera',['allow_dns_query'])
      if ns.empty?
        # no nameservers known for this hoster
        nodeinfo['misc']['resolver-recursive'] = true

        if not allow_dns_q.empty?
          raise Puppet::ParseError, "No nameservers listed for #{nodeinfo['hoster']['name']} yet we should answer somebody's queries?  That makes no sense.  allow_dns_q: #{allow_dns_q}."
        end
      elsif (nodeinfo['misc']['v4addrs'] and (ns & nodeinfo['misc']['v4addrs']).size > 0) or
            (nodeinfo['misc']['v6addrs'] and (ns & nodeinfo['misc']['v6addrs']).size > 0)
        # this host is listed as a nameserver at this location
        nodeinfo['misc']['resolver-recursive'] = true

        if allow_dns_q.empty?
          raise Puppet::ParseError, "Host #{host} is listed as a nameserver for #{nodeinfo['hoster']['name']} but no allow_dns_query networks are defined for this location"
        end
      else
        nodeinfo['misc']['resolver-recursive'] = false
      end

      return(nodeinfo)
    rescue => e
      raise Puppet::ParseError, "Error in nodeinfo for node #{host}, yamlfile #{yamlfile}: #{e.message}\n#{e.backtrace}"
    end
  end
end

# vim: set fdm=marker ts=2 sw=2 et:
