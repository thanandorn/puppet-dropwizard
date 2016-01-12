require 'spec_helper'

describe 'dropwizard::instance', :type => :define do

  let(:title) { 'Wicked' }

  context 'package => app-dep' do
    let(:params) { {:package => 'app-dep'} }
    it { should contain_package('app-dep').with(
      :ensure => 'present',
      :before => 'Service[dropwizard_Wicked]'
    )}
  end

  context 'sysconfig_path => /etc/sysconfig' do
    let(:params) { {:sysconfig_path => '/etc/sysconfig'} }
    it { should contain_file('/etc/sysconfig/dropwizard_Wicked').with(
      :ensure  => 'present',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0644',
      :notify  => 'Service[dropwizard_Wicked]',
    )}
  end

  context 'config_path => /etc/dropwizard' do
    let (:params) {{
      :config_path => '/etc/dropwizard',
      :user        => 'dropwizard',
      :group       => 'dropwizard',
    }}

    it { should contain_file('/etc/dropwizard/Wicked.yaml').with(
      :ensure  => 'present',
      :owner   => 'dropwizard',
      :group   => 'dropwizard',
      :mode    => '0640',
      :notify  => 'Service[dropwizard_Wicked]',
    )}
  end

  describe 'when deploying tar.gz' do
    it { should contain_exec('systemctl-daemon-reload').with(
      :command     => '/bin/systemctl daemon-reload',
      :refreshonly => true 
    )}
  end

  describe 'Install systemd service file' do
    it { should contain_file('/usr/lib/systemd/system/dropwizard_Wicked.service').with(
      :ensure  => 'present',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0644',
      :notify  => 'Exec[systemctl-daemon-reload]',
    )}
  end

  describe 'Manage dropwizard service' do
    it { should contain_service('dropwizard_Wicked').with(
      :ensure    => 'running',
      :enable    => true,
      :subscribe => 'Exec[systemctl-daemon-reload]',
    )}
  end

end
