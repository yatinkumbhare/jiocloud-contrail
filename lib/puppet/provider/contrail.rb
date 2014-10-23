require 'json'
require 'net/http'
require 'uri'
class Puppet::Provider::Contrail < Puppet::Provider

  ##
  #
  ##

  def self.getUrlData(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    if res.code == '200'
      data = JSON.parse(res.body)
      return data
    else
      raise(Puppet::Error,"Uri: #{uri.to_s} reutrned invalid return code #{res.code}")
    end
  end

  def getObject(url,type)
    hash_data=self.class.getUrlData(url)
    @contrail_object={}
    case type
    when 'linklocal'
      hash_data['global-vrouter-configs'].each do |i|
        vrouterconfig_uri = URI(i['href'])
        res = Net::HTTP.get_response(vrouterconfig_uri)
        if res.code != '200'
          raise(Puppet::Error,"Uri: #{vrouterconfig_uri.to_s} reutrned invalid return code #{res.code}")
        end
        vrouterconfig_hash = JSON.parse(res.body)
        if vrouterconfig_hash['global-vrouter-config']['linklocal_services']
          vrouterconfig_hash['global-vrouter-config']['linklocal_services']['linklocal_service_entry'].each do  |ll_service|
            if ll_service['linklocal_service_name'].eql?resource[:name]
              @contrail_object = ll_service
            end
          end
        end
      end
    when 'control','router'
      hash_data['bgp-routers'].each do |i|
        bgprouter_uri = URI(i['href'])
        res = Net::HTTP.get_response(bgprouter_uri)   
        if res.code != '200'      
          raise(Puppet::Error,"Uri: #{bgprouter_uri.to_s} reutrned invalid return code
#{res.code}")
        end                       
        bgprouter_hash = JSON.parse(res.body)
        if bgprouter_hash['bgp-router']['fq_name'].include?(resource[:name])
          @contrail_object = bgprouter_hash['bgp-router']
        end
      end
    end
#    return @contrail_object
  end

  def getElement(name,parent=false)
    if parent
      return @contrail_object[parent][name]
    else
      return @contrail_object[name]
    end
  end

end
