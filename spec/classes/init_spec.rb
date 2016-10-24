require 'spec_helper'

describe 'dropwizard' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['CentOS'].each do |operatingsystem|
        ['7'].each do |operatingsystemrelease|

          let(:facts) {{
            :operatingsystem => operatingsystem,
            :osfamily        => osfamily,
            :path            => '/bin:/sbin:/usr/bin:/usr/sbin',
            :architecture    => 'x86_64',
            :concat_basedir  => '/foo'
          }}

          describe "dropwizard class with no parameters on #{operatingsystem} #{operatingsystemrelease}" do

            context 'default' do
              it { should contain_class('dropwizard').with(
                'config_path' => '/etc/dropwizard',
                'run_user'    => 'dropwizard',
                'run_group'   => 'dropwizard',
                'instances'   => {},
              )}

              it { should_not contain_dropwizard__instance('demoapp') }
              it { should contain_user('dropwizard').with_system(true) }
              it { should contain_group('dropwizard').with_system(true) }

              it { should contain_class('java') }
              it { should contain_file('/etc/dropwizard').with({
                'owner' => 'dropwizard',
                'group' => 'dropwizard',
                'mode'  => '0755',
              })}

            end

          end

        end
      end
    end
  end
end
