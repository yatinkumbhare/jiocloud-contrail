require 'spec_helper'

describe 'contrail::ifmap' do
  let (:facts) { {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :ipaddress       => '10.1.1.1',
  } }

  let (:param) { { :module_name => 'contrail' } }
  context 'with defaults' do
    it do
      should contain_file('/etc/contrail').with({
        'ensure'  => 'directory',
        'before'  => 'Package[ifmap-server]',
      })
      should contain_package('ifmap-server')
      should contain_file_line('add_basic_auth_user_reader_with_readonly').with({
        'ensure'  => 'present',
        'line'    => 'reader=ro',
        'match'   => '^[\s\t]*reader=',
        'path'    => '/etc/ifmap-server/authorization.properties',
        'require' => 'Package[ifmap-server]',
        'notify'  => 'Service[ifmap-server]',
      })
      should contain_file('/etc/ifmap-server/publisher.properties').with({
        'ensure'  => 'present',
        'require' => 'Package[ifmap-server]',
        'source'  => "puppet:///modules/contrail/publisher.properties",
        'notify'  => 'Service[ifmap-server]',
      })
      should contain_file('/etc/ifmap-server/basicauthusers.properties').with_content(/10.1.1.1:10.1.1.1[\n.]*10.1.1.1.dns:10.1.1.1.dns/)
      should contain_file('/etc/ifmap-server/basicauthusers.properties').with({
        'ensure'  => 'present',
        'require' => 'Package[ifmap-server]',
        'notify'  => 'Service[ifmap-server]',
      })
      should contain_service('ifmap-server').with({
        'ensure'  => 'running',
        'enable'  => true,
        'require' => 'Package[ifmap-server]',
      })
    end
  end
  context 'with control_ip_list' do
    let (:params) { { :control_ip_list => ['10.2.2.2','10.3.3.3'] } }
    it do
      should contain_file('/etc/ifmap-server/basicauthusers.properties').with_content(/10.2.2.2:10.2.2.2[\n.]+10.3.3.3:10.3.3.3[\n.]+10.2.2.2.dns:10.2.2.2.dns[\n.]+10.3.3.3.dns:10.3.3.3.dns/)
    end
  end

end
