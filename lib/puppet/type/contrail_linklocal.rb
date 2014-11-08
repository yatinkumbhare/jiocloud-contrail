Puppet::Type.newtype(:contrail_linklocal) do

  @doc = <<-'EOD'
  Provision linklocal services. Linklocal services are used to provide a way to
communicate the machines in virtual network to physical world. Vrouter will act
as a proxy for any linklocal services. Any traffic comming to $service_address and
$service_port will be proxied/forwarded to $ipfabric_service_address and
$ipfabric_service_port by contrail vrouters.

NOTE: the forward is happening on every contrail vrouters. The
service_address will be one of the linklocal ip address (169.254.0.0/16).
This facility is used to implement nova metadata proxy - note that, the traffic
will directly forwarded by vrouter on compute node which the vm hosted directly
to the destination.

  example:

  ## Below code will create linklocal service for nova metadata

  contrail_linklocal {'metadata':
    ensure                  => present,
    ipfabric_service_address=> '10.1.1.1',
    ipfabric_service_port   => 8775,
    admin_password          => 'pass',
    service_address         => '169.254.169.254',
    service_port            => 80,
  }

  EOD

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the service  to be added.'
    munge do |v|
      v.strip
    end
  end

  newparam(:api_server_address) do
    desc 'Contrail api server address'
    defaultto '127.0.0.1'
    munge do |v|
      v.strip
    end
  end

  newparam(:api_server_port) do
    desc 'Contrail api server port'
    defaultto '8082'
    newvalues(/^\d+$/)
    munge do |v|
      v.to_s
    end
  end


  newparam(:admin_user) do
    desc 'Keystone admin user name'
    defaultto 'admin'
    newvalues(/\S+/)
    munge do |v|
      v.strip
    end
  end

  newparam(:admin_password) do
    desc 'Keystone admin user password'
    munge do |v|
      v.strip
    end
  end

  newproperty(:service_address) do
    desc 'Local IP address on vrouter to listen for linklocal service. e.g for
metadata it is 169.254.169.254'
    munge do |v|
      v.strip
    end
  end

  newproperty(:service_port) do
    desc 'Local port number on vrouter to be listen the linklocal service.'
    munge do |v|
      Integer(v)
    end
  end

  # not passed as an array b/c that does not seem to work
  newproperty(:ipfabric_service_address) do
    desc 'Real IP address of linklocal service'
    def insync?(is)
      is == should
    end
  end

  newproperty(:ipfabric_service_port) do
    desc 'The port on real server for linklocal service'
    munge do |v|
      Integer(v)
    end
  end

  validate do
    raise(Puppet::Error, 'ipfabric_service_address is required') unless self[:ipfabric_service_address]
    raise(Puppet::Error, 'ipfabric_service_port is required') unless self[:ipfabric_service_port]
    raise(Puppet::Error, 'service_port is required') unless self[:service_port]
    raise(Puppet::Error, 'service_address is required') unless self[:service_address]
    raise(Puppet::Error, 'admin_password is required') unless self[:admin_password]
  end
end

