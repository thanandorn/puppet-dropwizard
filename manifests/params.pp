# == Class: dropwizard::params
class dropwizard::params {

  $config_path           = '/etc/dropwizard'
  $root_path             = '/opt'
  $java_distribution     = 'jdk'
  $java_package          = undef
  $java_version          = 'present'
  $java_alternative      = undef
  $java_alternative_path = undef
  $run_user              = 'dropwizard'
  $run_group             = 'dropwizard'

}
