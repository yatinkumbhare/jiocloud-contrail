require 'spec_helper'

describe 'contrail::config' do
  let :facts do
    {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistid       => 'ubuntu',
    :lsbdistcodename => 'trusty',
    :ipaddress       => '10.1.1.1',
    :hostname        => 'node1',
    }
  end

  let :params do
    {
      :keystone_host           => '10.1.1.2',
      :keystone_admin_token    => 'admin_token',
      :keystone_admin_password => 'admin_password',
      :keystone_auth_password  => 'auth_password',
      :contrail_ip             => '10.1.1.1',
    }
  end
  context 'with defaults' do
    it do
      should contain_package('contrail-config-openstack').with({'ensure' => 'present'})
      should contain_package('contrail-utils').with_ensure('present')
      should contain_package('neutron-plugin-contrail').with_ensure('present')
      should contain_file('/etc/contrail/ctrl-details').with_content( <<-CTRL.gsub(/^ {8}/, '')
        SERVICE_TOKEN=auth_password
        AUTH_PROTOCOL=http
        ADMIN_TOKEN=admin_token
        CONTROLLER=10.1.1.2
        QUANTUM=10.1.1.1
        QUANTUM_PORT=9697
        QUANTUM_PROTOCOL=http
        COMPUTE=None
        AMQP_SERVER=10.1.1.1
      CTRL
      )
      should contain_file('/etc/contrail/service.token').with_content(/admin_token/)
      should contain_file('/etc/contrail/contrail-api.conf').with_content(<<-API.gsub(/^ {8}/, '')
        [DEFAULTS]
        ifmap_server_ip=10.1.1.1
        ifmap_server_port=8443
        ifmap_username=api-server
        ifmap_password=api-server
        cassandra_server_list=10.1.1.1:9160
        listen_ip_addr=0.0.0.0
        listen_port=9100
        auth=keystone
        multi_tenancy=false
        log_file=/var/log/contrail/api.log
        disc_server_ip=10.1.1.1
        disc_server_port=5998
        zk_server_ip=10.1.1.1:2181
        redis_server_ip=10.1.1.1
        rabbit_server=10.1.1.1
        rabbit_port=5672
        rabbit_user=guest
        rabbit_password=guest

        [SECURITY]
        use_certs=false
        keyfile=/etc/contrail/ssl/private_keys/apiserver_key.pem
        certfile=/etc/contrail/ssl/certs/apiserver.pem
        ca_certs=/etc/contrail/ssl/certs/ca.pem

        [KEYSTONE]
        auth_host=10.1.1.2
        auth_protocol=http
        auth_port=35357
        admin_user=admin
        admin_password=admin_password
        admin_token=admin_token
        admin_tenant_name=openstack

        [QUOTA]
        quota_floating_ip=10
        quota_logical_router=20
        quota_security_group=50
        quota_security_group_rule=50
        quota_subnet=20
        quota_virtual_machine_interface=30
        quota_virtual_network=8        
      API
      )

      should contain_file('/etc/contrail/vnc_api_lib.ini').with_content(/[.\n]*AUTHN_SERVER= 10.1.1.2/)
      should contain_file('/etc/contrail/contrail-schema.conf').with_content(<<-SCHEMA.gsub(/^ {8}/, '')
        [DEFAULTS]
        ifmap_server_ip=10.1.1.1
        ifmap_server_port=8443
        ifmap_username=schema-transformer
        ifmap_password=schema-transformer
        api_server_ip=10.1.1.1
        api_server_port=8082
        zk_server_ip=10.1.1.1:2181
        log_file=/var/log/contrail/schema.log
        cassandra_server_list=10.1.1.1:9160
        disc_server_ip=10.1.1.1
        disc_server_port=5998

        [SECURITY]
        use_certs=false
        keyfile=/etc/contrail/ssl/private_keys/schema_xfer_key.pem
        certfile=/etc/contrail/ssl/certs/schema_xfer.pem
        ca_certs=/etc/contrail/ssl/certs/ca.pem

        [KEYSTONE]
        admin_user=admin
        admin_password=admin_password
        admin_tenant_name=openstack
        admin_token=admin_token
      SCHEMA
      )

      should contain_file('/etc/contrail/contrail_plugin.ini').with_content(<<-CONTRAIL_PLUGIN.gsub(/^ {8}/, '')
        [APISERVER]
        api_server_ip = 10.1.1.1
        api_server_port = 8082
        multi_tenancy = false
        contrail_extensions = ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam,policy:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_policy.NeutronPluginContrailPolicy,route-table:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_vpc.NeutronPluginContrailVpc

        [KEYSTONE]
        ;auth_url = http://10.1.1.2:35357/v2.0
        ;admin_token = admin_token
        admin_user=admin
        admin_password=admin_password
        admin_tenant_name=openstack
      CONTRAIL_PLUGIN
      )
      should contain_file('/etc/neutron/plugins/opencontrail/ContrailPlugin.ini').with({
        'ensure'  => 'link',
        'source'  => '/etc/contrail/contrail_plugin.ini',
      })
      should contain_service('contrail-api').that_subscribes_to('File[/etc/contrail/contrail-api.conf]')
      should contain_service('contrail-api').that_subscribes_to('File[/etc/contrail/vnc_api_lib.ini]')
      should contain_service('contrail-schema').that_subscribes_to('File[/etc/contrail/contrail-schema.conf]')
      should contain_file('/etc/contrail/contrail-discovery.conf').with_content(/zk_server_ip=10.1.1.1/)
      should contain_service('contrail-discovery').that_subscribes_to('File[/etc/contrail/contrail-discovery.conf]')
      should contain_contrail_control('node1').with({
       'ensure'        => 'present',
        'host_address'  => '10.1.1.1',
        'admin_password'=> 'admin_password',
        'require'       => 'Service[contrail-api]',
      })
      should contain_contrail_linklocal('metadata').with({
        'ensure'                  => 'present',
        'ipfabric_service_address'=> '10.1.1.1',
        'ipfabric_service_port'   => 8775,
        'admin_password'          => 'admin_password',
        'service_address'         => '169.254.169.254',
        'service_port'            => 80,
        'require'                 => 'Service[contrail-api]',
      })
    end
  end
  context 'when configuring routers' do
    before do
      params.merge!({
        :router_ip   => '1.1.1.1',
        :router_name => 'router1',
      })
    end
    it do
      should contain_contrail_router('router1').with({
        'ensure'        => 'present',
        'host_address'  => '1.1.1.1',
        'admin_password'=> 'admin_password',
        'require'       => 'Service[contrail-api]',
      })
    end
  end
  context 'when node is not the seed' do
    before do
      params.merge!({
        :router_ip   => '1.1.1.1',
        :router_name => 'router1',
        :seed        => false,
      })
    end
    it do
      should_not contain_contrail_router('router1')
      should_not contain_contrail_linklocal('metadata')
    end
  end
  context 'with svc-monitor' do
    before do
      params.merge!({
        :enable_svcmon => true
      })
    end
    it do
      should contain_file('/etc/contrail/svc-monitor.conf').with_content(<<-SVCMON.gsub(/^ {8}/, '')
        [DEFAULTS]
        ifmap_server_ip=10.1.1.1
        ifmap_server_port=8443
        ifmap_username=svc-monitor
        ifmap_password=svc-monitor
        api_server_ip=10.1.1.1
        api_server_port=8082
        log_file=/var/log/contrail/svc-monitor.log
        zk_server_ip=10.1.1.1:2181
        cassandra_server_list=10.1.1.1:9160
        disc_server_ip=10.1.1.1
        disc_server_port=5998
        region_name=RegionOne

        [SECURITY]
        use_certs=false
        keyfile=/etc/contrail/ssl/private_keys/svc_monitor_key.pem
        certfile=/etc/contrail/ssl/certs/svc_monitor.pem
        ca_certs=/etc/contrail/ssl/certs/ca.pem

        [KEYSTONE]
        auth_host=10.1.1.2
        auth_protocol=http
        auth_port=35357
        admin_user=admin
        admin_password=admin_password
        admin_token=admin_token
        admin_tenant_name=openstack
      SVCMON
      )
      should contain_package('python-six').with_ensure('latest')
      should contain_service('contrail-svc-monitor').that_subscribes_to('File[/etc/contrail/svc-monitor.conf]')
    end
  end
end
