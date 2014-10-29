require 'json'
require 'net/http'
require 'uri'
class Puppet::Provider::ContrailBGP < Puppet::Provider

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

  ##
  # Return contrail object as well as it set an instance variable with contrail
  ##
  def getObject(url,name)
    @bgp_obj ||= {}
    @bgp_obj['vendor'] || getUrlData(url)['bgp-routers'].each do |i|
      if i['fq_name'].include?(name)
        @bgp_obj = getUrlData(i['href'])['bgp-router']['bgp_router_parameters']
        return @bgp_obj
      end
    end
    return  @bgp_obj 
  end


  def getElement(url,node,name)
    return getObject(url,node)[name]
  end
end
