require 'json'
require 'net/http'
require 'uri'
class Puppet::Provider::ContrailLinklocal < Puppet::Provider

  def getUrlData(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    if res.code == '200'
      data = JSON.parse(res.body)
      return data
    else
      raise(Puppet::Error,"Uri: #{uri.to_s} reutrned invalid return code #{res.code}")
    end
  end

  def getObject(url,name)
    @linklocal_obj ||= {}
    @linklocal_obj['linklocal_service_name'] || getUrlData(url)['global-vrouter-configs'].each do |i|
      res = Net::HTTP.get_response(URI(i['href']))
      if res.code != '200'
          raise(Puppet::Error,"Fetching global-vrouter-config failed")
      end
      vrouterconfig_hash = JSON.parse(res.body)
      if vrouterconfig_hash['global-vrouter-config']['linklocal_services']
        vrouterconfig_hash['global-vrouter-config']['linklocal_services']['linklocal_service_entry'].each do  |ll_service|
          if ll_service['linklocal_service_name'].eql?(name)
            @linklocal_obj = ll_service
            return @linklocal_obj
          end
        end
      end
    end
    return @linklocal_obj
  end

  def getElement(url,node,name)
    return getObject(url,node)[name]
  end
end
