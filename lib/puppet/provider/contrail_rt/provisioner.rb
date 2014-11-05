require_relative '../contrailBGP'

Puppet::Type.type(:contrail_rt).provide(
  :provisioner,
  :parent => Puppet::Provider::ContrailBGP
) do

  commands  :add_rt => '/usr/sbin/contrail-add-route-target',
            :del_rt => '/usr/sbin/contrail-del-route-target'

  def getUrl
    'http://' + resource[:api_server_address] + ':' + resource[:api_server_port] + '/virtual-networks'
  end

  def getObject(url,name)
    @rt_obj ||= {}
    @rt_obj['route_target'] || getUrlData(url)['virtual-networks'].each do |i|
      if i['fq_name'].sort == resource[:name].sort
        obj = getUrlData(i['href'])['virtual-network']['route_target_list']
        @rt_obj = obj.nil? ? {} : obj
        return @rt_obj
      end
    end
    return  @rt_obj
  end

  def exists?
     !getObject(getUrl,resource[:name]).empty?
  end

  def create
    add_rt(
      '--admin_user',resource[:admin_user],
      '--admin_password',resource[:admin_password],
      '--admin_tenant_name',resource[:admin_tenant],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port',resource[:api_server_port],
      '--routing_instance_name',resource[:name].join(':'),
      '--router_asn',resource[:router_asn],
      '--route_target_number',resource[:rt_number])
  end

  def destroy
    del_rt(
      '--admin_user',resource[:admin_user],
      '--admin_password',resource[:admin_password],
      '--admin_tenant_name',resource[:admin_tenant],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port',resource[:api_server_port],
      '--routing_instance_name',resource[:name].join(':'),   
      '--router_asn',resource[:router_asn],        
      '--route_target_number',resource[:rt_number])
  end

  ##
  # As of now there is only one route target per network. The logic which gets
  # first element in route_target array  may have to
  # change in future once we have multiple RTs.
  ##
  def rt_number
    getObject(getUrl,resource[:name])['route_target'][0].split(':')[2]
  end            
                 
  def rt_number=(value)
    fail('Cannot change Existing value, please remove and recreate the RT object (' + resource[:name].join(':') + ')')
  end 

  def router_asn
    getObject(getUrl,resource[:name])['route_target'][0].split(':')[1]
    
  end

  def router_asn=(value)
    fail('Cannot change Existing value, please remove and recreate the RT object (' + resource[:name].join(':') + ')')
  end

end
