# Define: dropwizard::instance
define dropwizard::instance (
  $ensure          = 'present',
  $version         = '0.0.1-SNAPSHOT',
  $package         = undef,
  $user            = $::dropwizard::run_user,
  $group           = $::dropwizard::run_group,
  $jar_file        = undef,
  $base_path       = $::dropwizard::base_path,
  $config_path     = $::dropwizard::config_path,
  $config_files    = [],
  $config_hash     = {
    'server' => {
      'type'             => 'simple',
      'appContextPath'   => '/application',
      'adminContextPath' => '/admin',
      'connector'        => {
        'type' => 'http',
        'port' => '8080'
      }
    }
  },

) {

  # Package Installation
  if $package != undef {
    package { $package:
      ensure => $ensure,
      before => Service["dropwizard_${name}"],
    }
  }

  # Single config file
  if count($config_files) == 0 {
    $_config_files = [ "${config_path}/${name}.yaml" ]
  } else {
    $_config_files = $config_files
  }

  file { "${config_path}/${name}.yaml":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => inline_template('<%= @config_hash.to_yaml.gsub("---\n", "") %>'),
    require => File[$config_path],
    notify  => Service["dropwizard_${name}"],
  }

  # Assign default jar
  if $jar_file == undef {
    $_jar_file = "${base_path}/${name}/${name}-${version}.jar"
  } else {
    $_jar_file = $jar_file
  }

  file { "/usr/lib/systemd/system/dropwizard_${name}.service":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/service/dropwizard.systemd.erb'),
  }

  $service_ensure = $ensure ? {
    /present/ => 'running',
    /absent/  => 'stopped',
  }

  $service_enable = $ensure ? {
    /present/ => true,
    /absent/  => false,
  }

  service { "dropwizard_${name}":
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File["/usr/lib/systemd/system/dropwizard_${name}.service"],
  }
}
