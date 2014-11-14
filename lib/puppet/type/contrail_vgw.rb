Puppet::Type.newtype(:contrail_vgw) do

  @doc = <<-'EOD'
  Provision contrail vgw interface to setup simple Gateway. Simple gateway is
used to provide external network connectivity without any physical router, in
test and development environments.
Note: This should not be used in production environment. As per contrail
documentation simple gateway is a restricted implementation of gateway which can
be used for experimental purposes.

  example:

  ## Below code will create vgw service for nova metadata

  contrail_vgw {'vgw1':
    ensure  => present,
    subnets => ['10.1.1.0/24'],
    dest_net=> ['0.0.0.0/0'],
    vrf     => 'default-domain:services:public:public'
  }

  EOD

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of VGW interface to add'
    munge do |v|
      v.strip
    end
  end

  ##
  # subnets, vrf, and dest_net should be properties, but it need bit more
  # investigation to understand a reliable way of determining thier value.
  # After that these would be changed as properites.
  ##
  newparam(:subnets, :array_matching => :all) do
    desc 'An array of subnets in CIDR format (e.g. 10.0.0.0/24) for which the
          gateway to be added'
    def insync?(is)
      is.sort == should.sort
    end
  end

  newparam(:dest_net, :array_matching => :all) do
    desc 'An array of destination networks in CIDR format'
    def insync?(is)
      is.sort == should.sort
    end
  end

  newparam(:vrf) do
    desc 'Contrail fqname of the VRF on which the route to be added. e.g
        default-domain:services:public:public is the fqname for the VRF
        of public VN in services tenant'
    munge do |v|
      v.strip
    end
  end

  validate do
    raise(Puppet::Error, 'vrf is required') unless self[:vrf]
    raise(Puppet::Error, 'dest_net is required') unless self[:dest_net]
    raise(Puppet::Error, 'subnets is required') unless self[:subnets]
  end
end

