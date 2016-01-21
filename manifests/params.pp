# == Class: dropwizard::params
class dropwizard::params {

  $config_path           = '/etc/dropwizard'
  $config_mode           = '0640'
  $sysconfig_path        = '/etc/sysconfig'
  $base_path             = '/opt'
  $run_user              = 'dropwizard'
  $run_group             = 'dropwizard'

}
