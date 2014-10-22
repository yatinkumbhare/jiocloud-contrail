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
    let :params do
      {
        :keystone_host           => '10.1.1.2',
        :keystone_admin_token    => 'admin_token',
        :keystone_admin_password => 'admin_password',
        :keystone_auth_password  => 'auth_password'
      }
    end
    it do
      should contain_class('contrail::system_config')
      should contain_class('contrail::ifmap').with({
        'control_ip_list' => ['10.1.1.1'],
      })

      should contain_class('contrail::config').with({
        'keystone_host'              => '10.1.1.2',
        'keystone_admin_token'       => 'admin_token',
        'keystone_admin_password'    => 'admin_password',
        'keystone_auth_password'     => 'auth_password',
        'keystone_region'            => 'RegionOne',
        'package_name'               => 'contrail-config-openstack',
        'package_ensure'             => 'present',
        'keystone_admin_port'        => 35357,
        'keystone_protocol'          => 'http',
        'haproxy_enabled'            => true,
        'neutron_ip'                 => '10.1.1.1',
        'neutron_port'               => 9697,
        'neutron_protocol'           => 'http',
        'config_ip'                  => '10.1.1.1',
        'use_certs'                  => false,
        'cassandra_ip_list'          => ['10.1.1.1'],
        'api_listen'                 => '0.0.0.0',
        'api_local_listen_port'      => 9100,
        'api_server_port'            => 8082,
        'multi_tenancy'              => false,
        'memcache_servers'           => '127.0.0.1:11211',
        'zk_ip_list'                 => ['10.1.1.1'],
        'redis_ip'                   => '10.1.1.1',
        'rabbit_ip'                  => '10.1.1.1',
        'discovery_listen'           => '0.0.0.0',
        'discovery_local_listen_port'=> 9110,
        'discovery_server_port'      => 5998,
        'hc_interval'                => 5
      })

      should_not contain_class('contrail::repo')
    end
  end

  context 'with control node, manage_repo' do
    let :params do
      {
        :control_ip_list         => ['10.1.1.1','10.1.1.2','10.1.1.3'],
        :keystone_host           => '10.1.1.2',
        :keystone_admin_token    => 'admin_token',
        :keystone_admin_password => 'admin_password',
        :keystone_auth_password  => 'auth_password',
        :manage_repo             => true,
      }
    end

    it do
      should contain_class('contrail::ifmap').with({
        'control_ip_list' => ['10.1.1.1','10.1.1.2','10.1.1.3'],
      })
      should contain_class('contrail::repo')
    end
  end
end
