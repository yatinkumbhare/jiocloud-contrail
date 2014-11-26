require 'puppet'
require 'spec_helper'
require 'puppet/provider/contrail_linklocal/provisioner'

describe Puppet::Type.type(:contrail_linklocal).provider(:provisioner) do

  let :base_opts do
    {
      'name' => 'foo',
      'ipfabric_service_address' => '127.0.0.1',
      'ipfabric_service_port'    => '80',
      'service_port'             => '80',
      'service_address'          => '127.0.0.1',
      'admin_password'           => 'pass',
    }
  end

  def create_provider(overrides)
    resource = Puppet::Type::Contrail_linklocal.new(base_opts.merge(overrides))
    described_class.new(resource)
  end

  it 'should create with an ip address for fabric' do
    p = create_provider({
      'ipfabric_service_address' => '127.0.0.1'
    })
    p.expects(:provision_linklocal).with do |*args|
      args.include?('--ipfabric_service_ip')
    end
    p.expects(:getElement).with(
      'http://127.0.0.1:8082/global-vrouter-configs',
      'foo',
      'ip_fabric_service_ip'
    )
    p.create
    p.ipfabric_service_address
  end

  it 'should create with a hostname for fabric' do
    p = create_provider({
      'ipfabric_service_address' => 'host.name'
    })
    p.expects(:provision_linklocal).with do |*args|
      args.include?('--ipfabric_dns_service_name')
    end
    p.expects(:getElement).with(
      'http://127.0.0.1:8082/global-vrouter-configs',
      'foo',
      'ip_fabric_DNS_service_name'
    )
    p.create
    p.ipfabric_service_address
  end

end
