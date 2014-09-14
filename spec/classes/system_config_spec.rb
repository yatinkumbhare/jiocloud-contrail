require 'spec_helper'

describe 'contrail::system_config' do
  let(:default_facts) { {:hostname => 'testnode', :ipaddress => '10.1.1.1'}}
  context 'On any Operating system' do
    let (:facts) {default_facts}
    it 'should contain' do
      should contain_host('testnode').with_ip('10.1.1.1')
      should contain_sysctl__value('net.ipv4.ip_forward').with_value('1')
    end
  end
  context 'On Ubuntu' do
    let :facts do
      default_facts.merge({
         :operatingsystem => 'Ubuntu',
         :osfamily        => 'Debian'
      })
    end
    it 'should contain' do
      should contain_exec('disable-ufw').with_command('ufw disable')
      should contain_file_line('daemon-core-file-unlimited').with_path('/etc/security/limits.conf')
       should_not contain_exec('selinux_disable_runtime').with_command(/setenforce 0/)
      should_not contain_file_line('contrail_selinux_disable_persistant').with_path('/etc/sysconfig/init')
      should_not contain_service('iptables').with({
        'enable' => 'false',
        'ensure' => 'stopped'
      })
    end
  end
  context 'On Redhat systems' do
    let :facts do
      default_facts.merge({
         :operatingsystem => 'Centos',
         :osfamily        => 'Redhat'
      })
    end
    it 'should contain' do
      should contain_exec('selinux_disable_runtime').with_command(/setenforce 0/)
      should contain_file_line('contrail_selinux_disable_persistant').with_path('/etc/sysconfig/init')
      should contain_service('iptables').with({
        'enable' => 'false',
        'ensure' => 'stopped'
      })
      should_not contain_file_line('daemon-core-file-unlimited').with_path('/etc/security/limits.conf')
      should_not contain_exec('disable-ufw').with_command('ufw disable')
    end
  end
end
