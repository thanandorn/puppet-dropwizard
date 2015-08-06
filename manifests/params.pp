# == Class: dropwizard::params
class dropwizard::params {

  $config_path           = '/etc/dropwizard'
  $base_path             = '/opt'
  $java_distribution     = 'jdk'
  $java_package          = undef
  $java_version          = 'present'
  $java_alternative      = undef
  $java_alternative_path = undef
  $run_user              = 'dropwizard'
  $run_group             = 'dropwizard'
  $proxy                 = false
  $location_defaults     = {
    'vhost' => 'dropwizard',
  }
  $virtual_hosts         = {
    'dropwizard'         => {
      'server_name'          => ["dropwizard"],
      'use_default_location' => false,
    }
  }

}
