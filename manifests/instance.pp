# Define: dropwizard::instance
define dropwizard::instance (
  $ensure          = 'present',
  $version         = '0.0.1-SNAPSHOT',
  $package         = undef,
  $jar_file        = undef,
  $user            = $::dropwizard::run_user,
  $group           = $::dropwizard::run_group,
  $base_path       = $::dropwizard::base_path,
  $sysconfig_path  = $::dropwizard::sysconfig_path,
  $config_path     = $::dropwizard::config_path,
  $config_files    = [],
  $sysconfig_hash  = {
    'JAVA_CMD' => '/bin/java'
  },
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

  file { "${sysconfig_path}/dropwizard_${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/sysconfig/dropwizard.sysconfig.erb'),
    notify  => Service["dropwizard_${name}"],
  }

  file { "${config_path}/${name}.yaml":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => inline_template('<%= @config_hash.to_yaml.gsub("---\n", "") %>'),
    require => File[$config_path,"${sysconfig_path}/dropwizard_${name}"],
    notify  => Service["dropwizard_${name}"],
  }

  # Assign default jar
  if $jar_file == undef {
    $_jar_file = "${base_path}/${name}/${name}-${version}.jar"
  } else {
    $_jar_file = $jar_file
  }

  # This is required to make reload systemd and pick up the newest service definitions
  exec {
    "systemctl-daemon-reload-dropwizard_${name}":
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
  }

  file { "/usr/lib/systemd/system/dropwizard_${name}.service":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/service/dropwizard.systemd.erb'),
    notify  => Exec["systemctl-daemon-reload-dropwizard_${name}"]
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
    ensure    => $service_ensure,
    enable    => $service_enable,
    subscribe => Exec["systemctl-daemon-reload-dropwizard_${name}"]
  }
}
