Puppet::Type.newtype(:contrail_fip_pool) do

  @doc = <<-'EOD'
  Provision floating ips using contrail apis and provide access to certain projects.
This is required if you need a floating IP pool which are only shared to specific tenants.
If you use neutron apis, the floating IP pool will be shared with all tenants.

  example:

  ## Below code will create floating ip with access to the tenants, tenant1, tenant2

  contrail_fip_pool {'fip1':
    ensure         => present,
    network_fqname => default-domain:tenant:fip_net1,
    tenants        => ['tenant1','tenant2'],
  }

  EOD

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Floating ip pool name'
    munge do |v|
      v.strip
    end
  end

  newparam(:network_fqname) do
    desc 'Fully qualified name for network on which the fip pool to be created.'
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

  newproperty(:tenants, :array_matching => :all) do
    desc 'An array of project fqnames which will have access to this fip pool'
    def insync?(is)
      is.sort == should.sort
    end
  end
end
