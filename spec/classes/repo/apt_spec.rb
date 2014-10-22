require 'spec_helper'

describe 'contrail::repo::apt' do
  let (:facts) { {
    :lsbdistid       => 'ubuntu',
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
  } }

  context 'with defaults' do
    it do
      should contain_apt__source('opencontrail').with({
        'location'  => 'http://ppa.launchpad.net/opencontrail/ppa/ubuntu',
        'release'   => 'trusty',
        'repos'     => 'main',
        'include_src'=> false,
        'key'       => '6839FE77',
      })
    end
  end
end
