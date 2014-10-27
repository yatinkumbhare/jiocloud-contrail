require 'spec_helper'

describe 'contrail::collector' do
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
      should contain_package('contrail-analytics').with({'ensure' => 'present'})
      should contain_file('/etc/contrail/contrail-analytics-api.conf').with_content( <<-EOF.gsub(/^ {8}/, '')
        [DEFAULTS]
        host_ip = 10.1.1.1
        collectors = 10.1.1.1:8086
        http_server_port = 8090
        rest_api_port = 8081
        rest_api_ip = 0.0.0.0
        log_local = 0
        log_level = SYS_DEBUG
        log_category =
        log_file = /var/log/contrail/contrail-analytics-api.log

        [DISCOVERY]
        disc_server_ip = 10.1.1.1
        disc_server_port = 5998

        [REDIS]
        redis_server_port = 6379
        redis_query_port = 6379
        EOF
      )
      should contain_service('contrail-analytics-api').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/contrail-analytics-api.conf]',
      })
      should contain_file('/etc/contrail/contrail-collector.conf').with_content(/cassandra_server_list=10.1.1.1:9160/)
      should contain_file('/etc/contrail/contrail-collector.conf').with_content(/hostip=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-collector.conf').with_content(/analytics_data_ttl=48/)
      should contain_Service('contrail-collector').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/contrail-collector.conf]'
      })
      should contain_file('/etc/contrail/contrail-query-engine.conf').with_content(/cassandra_server_list=10.1.1.1:9160/)
      should contain_file('/etc/contrail/contrail-query-engine.conf').with_content(/hostip=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-query-engine.conf').with_content(/analytics_data_ttl=48/)
      should contain_Service('contrail-query-engine').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/contrail-query-engine.conf]',
      })
      should contain_file('/etc/init.d/contrail-analytics-api').with({
        'ensure' => 'link',
        'source' => '/lib/init/upstart-job',
        'require'=> 'Package[contrail-analytics]',
      })
      should contain_file('/etc/init.d/contrail-analytics-api').with({
        'ensure' => 'link',  
        'source' => '/lib/init/upstart-job',
        'require'=> 'Package[contrail-analytics]',
      })
      should contain_file('/etc/init.d/contrail-collector').with({
        'ensure' => 'link',  
        'source' => '/lib/init/upstart-job',
        'require'=> 'Package[contrail-analytics]',
      })
    end
  end
end
