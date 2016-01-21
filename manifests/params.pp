# == Class: dropwizard::params
class dropwizard::params {

  $config_path    = '/etc/dropwizard'
  $sysconfig_path = '/etc/sysconfig'
  $base_path      = '/opt'
  $run_user       = 'dropwizard'
  $run_group      = 'dropwizard'
  $config_mode    = '0640'

}
