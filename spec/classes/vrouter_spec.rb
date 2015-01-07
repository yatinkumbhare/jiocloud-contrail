require 'spec_helper'

describe 'contrail::vrouter' do
  let :facts do
    {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistid       => 'ubuntu',
    :lsbdistcodename => 'trusty',
    :ipaddress       => '10.1.1.1',
    :hostname        => 'node1',
    :interfaces      => 'eth0',
    :netmask_eth0    => '255.255.255.0',
    :network_eth0    => '10.1.1.0',
    }
  end

  let :params do
    {
    :discovery_address       => '1.2.3.4',
    :keystone_admin_password => 'admin_password',
    }
  end
  context 'with defaults' do
    it do
	  should_not contain_class('contrail::repo')
    end
  end
  context 'with manage_repo set to true' do
    before do
      params.merge!({
        :manage_repo   => true,
      })
    end
    it do
	  should contain_class('contrail::repo')
    end
  end
  context 'with manage_repo set to random nonsense' do
    before do
      params.merge!({
        :manage_repo   => 'random nonsense',
      })
    end
    it do
      expect { should compile }.to raise_error(/is not a boolean/)
    end
  end
end
