require 'spec_helper'

describe 'dropwizard', :type => :class do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['CentOS'].each do |operatingsystem|
        ['7'].each do |operatingsystemrelease|

          describe "dropwizard class with no parameters on OS family #{operatingsystem}/#{osfamily}" do
            let(:facts) {{
              :operatingsystem => operatingsystem,
              :osfamily        => osfamily,
              :path            => '/bin:/sbin:/usr/bin:/usr/sbin',
              :architecture    => 'x86_64'
            }}

            it { should contain_class('dropwizard') }
            it { should contain_class('java') }
            it { should contain_class('nginx') }
            it { should contain_package('nginx') }

          end
        end
      end
    end
  end
end
