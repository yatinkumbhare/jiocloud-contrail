require 'spec_helper'

describe 'contrail' do
  let :facts do
    {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistid       => 'ubuntu',
    :lsbdistcodename => 'trusty',
    :ipaddress       => '10.1.1.1',
    }
  end

  context 'with defaults' do
    it do
      should contain_class('contrail::system_config')
      should contain_class('contrail::ifmap').with({
        'control_ip_list' => ['10.1.1.1'],
      })
    end
  end

  context 'with control node' do
    let (:params) { { :control_ip_list => ['10.1.1.1','10.1.1.2','10.1.1.3'] } }

    it {  should contain_class('contrail::ifmap').with({
        'control_ip_list' => ['10.1.1.1','10.1.1.2','10.1.1.3'],
      }) }
  end
end
