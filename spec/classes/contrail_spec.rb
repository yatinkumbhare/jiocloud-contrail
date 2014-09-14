require 'spec_helper'

describe 'contrail' do
  let :facts do
    {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistid       => 'ubuntu',
    :lsbdistcodename => 'trusty'
    }
  end
  context 'with defaults' do
    it do
      should contain_class('contrail::system_config')
    end
  end
end
