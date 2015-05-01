require_relative '../contrailLinklocal'
require "ipaddr"

Puppet::Type.type(:contrail_linklocal).provide(
  :provisioner,
  :parent => Puppet::Provider::ContrailLinklocal
) do

  commands  :provision_linklocal => '/usr/sbin/contrail-provision-linklocal'

  def getUrl
    'http://' + resource[:api_server_address] + ':' + resource[:api_server_port] + '/global-vrouter-configs'
  end

  def exists?
    !getObject(getUrl,resource[:name]).empty?
  end

  def invalid_address_error
    if IPAddr.const_defined?('InvalidAddressError')
      IPAddr::InvalidAddressError
    else
      ArgumentError
    end
  end

  def create_or_update
    args = [
      '--admin_user', resource[:admin_user],
      '--admin_password', resource[:admin_password],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port', resource[:api_server_port],
      '--linklocal_service_name', resource[:name],
      '--linklocal_service_ip', resource[:service_address],
      '--linklocal_service_port', resource[:service_port],
      '--ipfabric_service_port', resource[:ipfabric_service_port],
    ]
    addr = resource[:ipfabric_service_address]
    begin
      if IPAddr.new(addr).ipv4? || IPAddr.new(addr).ipv6?
        args.push('--ipfabric_service_ip')
      end
    rescue invalid_address_error
      if addr == ''
        raise(Puppet::Error, 'Cannot pass empty ipfabric address')
      else
        args.push('--ipfabric_dns_service_name')
      end
    end
    args.push(addr)
    args.push('--oper add')
    provision_linklocal(*args)
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
    getElement(getUrl,resource[:name],'linklocal_service_ip')
  end

  def service_address=(value)
    create_or_update
  end

  def service_port
    getElement(getUrl,resource[:name],'linklocal_service_port')
  end

  def service_port=(value)
    create_or_update
  end

  def ipfabric_service_address
    addr = resource[:ipfabric_service_address]
    begin
      if IPAddr.new(addr).ipv4? || IPAddr.new(addr).ipv6?
        return getElement(getUrl,resource[:name],'ip_fabric_service_ip')
      end
    rescue invalid_address_error
      return getElement(getUrl,resource[:name], 'ip_fabric_DNS_service_name')
    end
  end

  def ipfabric_service_address=(value)
    create_or_update
  end

  def ipfabric_service_port
    getElement(getUrl,resource[:name],'ip_fabric_service_port')
  end

  def ipfabric_service_port=(value)
    create_or_update
  end

end
