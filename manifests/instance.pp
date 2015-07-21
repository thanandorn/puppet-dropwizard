# Define: dropwizard::instance
define dropwizard::instance (
  $ensure        = 'present',
  $version       = '0.0.1-SNAPSHOT',
  $package       = undef,
  $user          = $::dropwizard::run_user,
  $group         = $::dropwizard::run_group,
  $http_port     = '8080',
  $root_path     = '/opt',
  $conf_path     = $::dropwizard::config_path,
  $conf_hash     = {
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

  nginx::resource::upstream { "dropwizard_${name}":
    members => [ "http://localhost:${http_port}" ],
  }

  nginx::resource::vhost { $name:
    proxy => "http://dropwizard_${name}",
  }

  if $package != undef {
    package { $package:
      ensure => $ensure,
      before => Service[$name],
    }
  }

  file { "${conf_path}/${name}.yaml":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    content => inline_template('<%= @conf_hash.to_yaml %>'),
    require => File['/etc/dropwizard'],
    notify  => Service[$name],
  }

  file { "/usr/lib/systemd/system/${name}.service":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/service/systemd/dropwizard.service.erb'),
  }

  $service_ensure = $ensure ? {
    /present/ => 'running',
    /absent/  => 'stopped',
  }

  $service_enable = $ensure ? {
    /present/ => true,
    /absent/  => false,
  }

  service { $name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File["/usr/lib/systemd/system/${name}.service"],
  }
}
