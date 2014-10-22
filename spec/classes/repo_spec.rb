require 'spec_helper'

describe 'contrail::repo' do
  let (:facts) { {
    :lsbdistid       => 'ubuntu',
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
  } }

  context 'with Debian' do
    it do
      should contain_class('contrail::repo::apt')
    end
  end
  context 'with Other osfamily' do
    let (:facts) { { :osfamily => 'redhat' } }
    it do
      expect { should compile }.to raise_error(/OS family redhat is not supported/)
    end
  end
end
