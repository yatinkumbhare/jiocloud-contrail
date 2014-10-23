 $LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/provider/contrail'

Puppet::Type.type(:contrail_bgp_provisioner).provide(
  :provisioner,
  :parent => Puppet::Provider::Contrail
) do

  commands  :provision_control => '/usr/sbin/contrail-provision-control',
            :provision_router  => '/usr/sbin/contrail-provision-mx'

  def getUrl
    url = 'http://' + resource[:api_server_address] + ':' + resource[:api_server_port] + '/bgp-routers'
  end

  def exists?
    getObject(getUrl,'router')
    !@contrail_object.empty?
  end

  def create
    if resource[:type].eql?'control'
      provision_control(
        '--admin_user',resource[:admin_user],
        '--admin_password',resource[:admin_password],
        '--api_server_ip', resource[:api_server_address],
        '--api_server_port',resource[:api_server_port],
        '--host_name',resource[:name],
        '--host_ip',resource[:host_address],
        '--router_asn',resource[:router_asn],
        '--admin_tenant_name',resource[:admin_tenant],
        '--oper add')
    else
      provision_router(
        '--admin_user',resource[:admin_user],
        '--admin_password',resource[:admin_password],
        '--api_server_ip',resource[:api_server_address],
        '--api_server_port',resource[:api_server_port],
        '--router_name',resource[:name],
        '--router_ip',resource[:host_address],
        '--router_asn',resource[:router_asn],
        '--admin_tenant_name',resource[:admin_tenant],
        '--oper add')
    end
  end

  def destroy
    if resource[:type].eql?'control'
      provision_control(
        '--admin_user',resource[:admin_user],
        '--admin_password',resource[:admin_password],
        '--admin_tenant_name',resource[:admin_tenant],
        '--api_server_ip', resource[:api_server_address],
        '--api_server_port',resource[:api_server_port],
        '--host_name',resource[:name],
        '--oper del')
    else
      provision_router(
        '--admin_user',resource[:admin_user],
        '--admin_password',resource[:admin_password],
        '--admin_tenant_name',resource[:admin_tenant],
        '--api_server_ip',resource[:api_server_address],
        '--api_server_port',resource[:api_server_port],
        '--router_name',resource[:name],
        '--oper del')
    end
  end

  def host_address
    getElement('address','bgp_router_parameters')
  end

  def host_address=(value)
    fail('Cannot change Existing value, please remove and recreate the router (' + resource[:name] + ')')
  end

  def router_asn
    getElement('autonomous_system','bgp_router_parameters')
  end

  def router_asn=(value)
    fail('Cannot change Existing value, please remove and recreate the router (' + resource[:name] + ')')
  end

end
