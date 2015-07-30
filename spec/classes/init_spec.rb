require 'spec_helper'

describe 'dropwizard' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['CentOS'].each do |operatingsystem|
        ['7'].each do |operatingsystemrelease|

          describe "dropwizard class with no parameters on OS family #{operatingsystem}/#{operatingsystemrelease}" do
            let(:facts) {{
              :operatingsystem => operatingsystem,
              :osfamily        => osfamily,
              :path            => '/bin:/sbin:/usr/bin:/usr/sbin',
              :architecture    => 'x86_64'
            }}

            context 'default (true)' do
              it { should contain_class('dropwizard') }
              it { should contain_class('java') }
              it { should contain_package('java') }
              it { should contain_class('nginx') }
              it { should contain_package('nginx') }
              it { should contain_service('nginx') }
            end
          end
        end
      end
    end
  end
end
