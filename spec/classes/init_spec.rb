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

              it { should contain_class('java').with(
                'java_alternative'      => nil,
                'java_alternative_path' => nil,
                'package'               => nil,
                'version'               => 'present',
                'distribution'          => 'jdk',
              )}

              it { should_not contain_class('nginx') }
              it { should_not contain_nginx__resource__vhost('dropwizard') }
              it { should_not contain_nginx__resource__location('dropwizard') }

            end
          end

          describe "dropwizard class with parameters on #{operatingsystem} #{operatingsystemrelease}" do
            context 'nginx proxy enabled' do
              let(:params) {{
                :proxy => true,
              }}

              it { should contain_class('dropwizard').with(
                'config_path' => '/etc/dropwizard',
                'run_user'    => 'dropwizard',
                'run_group'   => 'dropwizard',
                'proxy'       => true,
                'instances'   => {},
              )}

              it { should contain_class('nginx') }
              it { should contain_service('nginx') }
              it { should contain_nginx__resource__vhost('dropwizard') }
              it { should_not contain_nginx__resource__location('dropwizard') }

            end

            context 'nginx proxy enabled and instances configured' do
              let(:params) {{
                :proxy         => true,
                :virtual_hosts => {
                  'dropwizard'         => {
                    'server_name'          => ['dropwizard.example.com'],
                    'use_default_location' => false,
                  }
                },
                :instances => {
                  'demoapp'  => {
                    'nginx_locations' => {
                      'app'           => {
                        'proxy'      => 'http://localhost:8080',
                        'location'   => '^~ /app',
                      }
                    },
                    'config_hash' => {
                      "server"    => {
                        'type'             => 'simple',
                        'appContextPath'   => '/app',
                        'adminContextPath' => '/admin',
                        'connector'        => {
                          'type' => 'http',
                          'port' => '8080'
                        }
                      }
                    }
                  }
                },
              }}

              it { should contain_dropwizard__instance('demoapp') }
              it { should contain_service('dropwizard_demoapp') }
              it { should contain_file('/etc/dropwizard/demoapp.yaml') }
              it { should_not contain_package('demoapp') }


              it { should contain_nginx__resource__vhost('dropwizard').with(
                :server_name => ['dropwizard.example.com'],
              )}
              it { should contain_nginx__resource__location('app').with(
               :location  => '^~ /app',
               :proxy     => 'http://localhost:8080',
              )}

            end
          end
        end
      end
    end
  end
end
