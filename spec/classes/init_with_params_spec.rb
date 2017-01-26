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

          describe "dropwizard class with some parameters on #{operatingsystem} #{operatingsystemrelease}" do

            let(:params) {{
              :run_user    => 'dropwizard',
              :run_uid     => '500',
              :run_group   => 'dropwizard',
              :run_gid     => '500',
              :config_path => '/opt/dropwizard',
              :instances   => {
                'demoapp'   => {
                  'version' => '1.0'
                }
              },
            }}

            context 'default' do
              it { should contain_class('dropwizard').with(
                'base_path'      => '/opt',
                'config_path'    => '/opt/dropwizard',
                'run_user'       => 'dropwizard',
                'run_uid'        => '500',
                'run_group'      => 'dropwizard',
                'run_gid'        => '500',
                'sysconfig_path' => '/etc/sysconfig',
                'instances'      => {
                  'demoapp'      => {
                    'version'    => '1.0',
                  }
                },
              )}

              it { should contain_class('java') }
              it { should contain_user('dropwizard').with_system(true) }
              it { should contain_group('dropwizard').with_system(true) }

              it { should contain_file('/opt/dropwizard').with({
                'owner' => 'dropwizard',
                'group' => 'dropwizard',
                'mode'  => '0755',
              })}

              it { should contain_dropwizard__instance('demoapp').with(
                'version' => '1.0'
              )}

            end
          end
        end
      end
    end
  end
end
