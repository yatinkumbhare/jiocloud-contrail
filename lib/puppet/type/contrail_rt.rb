Puppet::Type.newtype(:contrail_rt) do

  @doc = <<-'EOD'
  Manage routetargets on contrail config database.

  example:

  ### Below code will add route target .
  contrail_rt {'default-domain:services:public':
    ensure             => present,
    rt_number          => '10001',
    router_asn         => 64510,
    api_server_address => '10.1.10.1',
    admin_password     => 'pass'
  }
  EOD

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Contrail FQ Name of the network in which RT is getting added.
          This must be in the form default-domain:<project_name>:<network_name>.
          E.g default-domain:services:public'
    newvalues(/default-domain:\S+:\S+/)
    munge do |v|
      v.strip.split(':')
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
    defaultto 8082
    newvalues(/^\d+$/)
    munge do |v|
      v.to_s
    end
  end

  newparam(:admin_user) do
    desc 'Keystone admin user name'
    defaultto 'admin'
    newvalues(/\S+/)
  end

  newparam(:admin_password) do
    desc 'Keystone admin user password'
  end

  newparam(:admin_tenant) do
    desc 'Keystone admin tenant name'
    defaultto 'openstack'
    newvalues(/\S+/)
  end

  newproperty(:rt_number) do
    desc 'Route Target Number, the same number is configured both edge router
          for public IP VRF'
    munge do |v|
      v.to_s
    end
  end

  newproperty(:router_asn) do                                                    
    desc 'Router ASN Number'
    defaultto 64510
    munge do |v|                                                                
      v.to_s
    end   
  end
  validate do
    raise(Puppet::Error, 'rt_number is required') unless self[:rt_number]
    raise(Puppet::Error, 'api_server_address is required') unless self[:api_server_address]
    raise(Puppet::Error, 'admin_password is required') unless self[:admin_password]
  end
end

