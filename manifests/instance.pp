# Define: dropwizard::instance
define dropwizard::instance (
  $package_ensure  = 'present',
  $file_ensure     = 'present',
  $service_ensure  = 'running',
  $service_enable  = true,
  $version         = '0.0.1-SNAPSHOT',
  $package         = undef,
  $jar_file        = undef,
  $sysconfig       = {},
  $user            = $::dropwizard::run_user,
  $group           = $::dropwizard::run_group,
  $mode            = $::dropwizard::config_mode,
  $base_path       = $::dropwizard::base_path,
  $sysconfig_path  = $::dropwizard::sysconfig_path,
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
      ensure => $package_ensure,
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
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/sysconfig/dropwizard.sysconfig.erb'),
    notify  => Service["dropwizard_${name}"],
  }

  file { "${config_path}/${name}.yaml":
    ensure  => $file_ensure,
    owner   => $user,
    group   => $group,
    mode    => $mode,
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

  file { "/usr/lib/systemd/system/dropwizard_${name}.service":
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/service/dropwizard.systemd.erb'),
    notify  => Exec["${name}-systemctl-daemon-reload"],
  }

  exec { "${name}-systemctl-daemon-reload":
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin','/bin','/sbin'],
    refreshonly => true,
  }

  service { "dropwizard_${name}":
    ensure    => $service_ensure,
    enable    => $service_enable,
    subscribe => Exec["${name}-systemctl-daemon-reload"],
  }
}
