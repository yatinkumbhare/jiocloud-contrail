require 'spec_helper'

describe 'contrail::webui' do
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
      should contain_package('contrail-web-core').with({'ensure' => 'present'})
      should contain_package('contrail-web-controller').with({'ensure' => 'present'})
      should contain_file('/etc/contrail/config.global.js').with_content(/config.networkManager.ip = '10.1.1.1'/)
      should contain_file('/etc/contrail/config.global.js').with_content(/config.imageManager.ip = '10.1.1.1'/)
      should contain_file('/etc/contrail/config.global.js').with_content(/config.computeManager.ip = '10.1.1.1'/)
      should contain_file('/etc/contrail/config.global.js').with_content(/config.identityManager.ip = '10.1.1.1'/)
      should contain_file('/etc/contrail/config.global.js').with_content(/config.cnfg.server_ip = '10.1.1.1'/)
      should contain_file('/etc/contrail/config.global.js').with_content(/config.analytics.server_ip = '10.1.1.1'/)
      should contain_file('/etc/init.d/contrail-webui-jobserver').with_target('/lib/init/upstart-job')
      should contain_file('/etc/init.d/contrail-webui-webserver').with_target('/lib/init/upstart-job')
      should contain_service('contrail-webui-jobserver').with_ensure('running')
      should contain_service('contrail-webui-webserver').with_ensure('running')
    end
  end
end
