$LOAD_PATH.push(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/provider/contrail'

Puppet::Type.type(:contrail_linklocal_provisioner).provide(
  :provisioner,
  :parent => Puppet::Provider::Contrail
) do

  commands  :provision_linklocal => '/usr/sbin/contrail-provision-linklocal'

  def getUrl
    'http://' + resource[:api_server_address] + ':' + resource[:api_server_port] + '/global-vrouter-configs'
  end

  def exists?
    getObject(getUrl,'linklocal')
    !@contrail_object.empty?
  end

  def create_or_update
    provision_linklocal(
      '--admin_user', resource[:admin_user],
      '--admin_password', resource[:admin_password],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port', resource[:api_server_port],
      '--linklocal_service_name', resource[:name],
      '--linklocal_service_ip', resource[:service_address],
      '--linklocal_service_port', resource[:service_port],
      '--ipfabric_service_ip', resource[:ipfabric_service_address],
      '--ipfabric_service_port', resource[:ipfabric_service_port],
      '--oper add')
  end

  def create
    create_or_update
  end

  def destroy
    provision_linklocal(
      '--admin_user', resource[:admin_user],
      '--admin_password', resource[:admin_password],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port', resource[:api_server_port],
      '--linklocal_service_name', resource[:name],
      '--oper del')
  end

  def service_address
   getElement('linklocal_service_ip')
  end

  def service_address=(value)
    create_or_update
  end

  def service_port
    getElement('linklocal_service_port')
  end

  def service_port=(value)
    create_or_update
  end

  def ipfabric_service_address
    getElement('ip_fabric_service_ip')
  end

  def ipfabric_service_address=(value)
    create_or_update
  end

  def ipfabric_service_port
    getElement('ip_fabric_service_port')
  end

  def ipfabric_service_port=(value)
    create_or_update
  end

end
