Puppet::Type.type(:contrail_vgw).provide(
  :provisioner
) do

  has_command(:provision_vgw, "/usr/sbin/contrail-provision-vgw-interface") do
    environment :PYTHONPATH => "/usr/lib/python2.7/dist-packages/contrail_vrouter_api/gen_py/instance_service"
  end

  def exists?
    Facter.value(:interfaces).split(',').include?(resource[:name])
  end

  def create
    provision_vgw(
      '--interface', resource[:name],
      '--subnets', resource[:subnets],
      '--routes', resource[:dest_net],
      '--vrf', resource[:vrf] ,
      '--oper create')
  end

  def destroy
    provision_vgw(
      '--interface', resource[:name],
      '--subnets', resource[:subnets],
      '--routes', resource[:dest_net],
      '--vrf', resource[:vrf],
      '--oper delete')
  end

end
