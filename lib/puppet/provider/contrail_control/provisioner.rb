require 'puppet/provider/contrailBGP'

Puppet::Type.type(:contrail_control).provide(
  :provisioner,
  :parent => Puppet::Provider::ContrailBGP
) do

  commands  :provision_control => '/usr/sbin/contrail-provision-control'

  def getUrl
    'http://' + resource[:api_server_address] + ':' + resource[:api_server_port] + '/bgp-routers'
  end

  def exists?
     !getObject(getUrl,resource[:name]).empty?
  end

  def create
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
  end

  def destroy
    provision_control(
      '--admin_user',resource[:admin_user],
      '--admin_password',resource[:admin_password],
      '--admin_tenant_name',resource[:admin_tenant],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port',resource[:api_server_port],
      '--host_name',resource[:name],
      '--oper del')
  end

  def host_address
    getElement(getUrl,resource[:name],'address')
  end

  def host_address=(value)
    fail('Cannot change Existing value, please remove and recreate the control node object (' + resource[:name] + ')')
  end

  def router_asn
    getElement(getUrl,resource[:name],'autonomous_system')
  end

  def router_asn=(value)
    fail('Cannot change Existing value, please remove and recreate the control node object (' + resource[:name] + ')')
  end

end
