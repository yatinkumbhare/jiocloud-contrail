require 'spec_helper'

describe 'contrail::control' do
  let :facts do
    {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistid       => 'ubuntu',
    :lsbdistcodename => 'trusty',
    :ipaddress       => '10.1.1.1',
    :hostname        => 'node1',
    :interfaces      => 'eth0,lo',
    :ipaddress_eth0  => '10.1.1.1',
    }
  end

  context 'with defaults' do
    it do
      should contain_package('contrail-control').with({'ensure' => 'present'})
      should contain_package('contrail-dns').with({'ensure' => 'present'})
      should contain_file('/etc/contrail/dns.conf').with_content(/hostip=10.1.1.1/)
      should contain_file('/etc/contrail/dns.conf').with_content(/hostname=node1/)
      should contain_file('/etc/contrail/dns.conf').with_content(/server=10.1.1.1/)
      should contain_file('/etc/contrail/dns.conf').with_content(/password=10.1.1.1.dns/)
      should contain_file('/etc/contrail/dns.conf').with_content(/user=10.1.1.1.dns/)
      should contain_service('contrail-dns').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/dns.conf]',
        'require'   => 'Package[contrail-dns]'
      })
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/hostip=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/hostname=node1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/server=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/password=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/user=10.1.1.1/)
      should contain_service('contrail-control').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/contrail-control.conf]',
        'require'   => 'Package[contrail-control]'
      })
    end
  end
end
