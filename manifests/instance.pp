# Define: dropwizard::instance
define dropwizard::instance (
  $ensure          = 'present',
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
  $config_hash     = {},

) {

  # Package Installation
  if $package != undef {
    package { $package:
      ensure => $ensure,
      before => Service["dropwizard_${name}"],
    }
  }

  file { "${sysconfig_path}/dropwizard_${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('dropwizard/sysconfig/dropwizard.sysconfig.erb'),
    notify  => Service["dropwizard_${name}"],
  }

  # Merged Config Hash
  $merged_config_file_hash = parseyaml(inline_template('<%= extra_config_hash = Hash.new ; @config_files.each { |file| extra_config_hash = extra_config_hash.merge(YAML.load_file(file)) } ; p extra_config_hash.to_yaml %>'))
  $merged_config_hash = deep_merge($merged_config_file_hash, $config_hash)

  file { "${config_path}/${name}.yaml":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    content => inline_template('<%= @merged_config_hash.to_yaml.gsub("---\n", "") %>'),
    require => File[$config_path,"${sysconfig_path}/dropwizard_${name}"],
    notify  => Service["dropwizard_${name}"],
  }

  # Assign default jar
  if $jar_file == undef {
    $_jar_file = "${base_path}/${name}/${name}-${version}.jar"
  } else {
    $_jar_file = $jar_file
  }

  file { "/lib/systemd/system/dropwizard_${name}.service":
    ensure  => $ensure,
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
    subscribe => Exec["${name}-systemctl-daemon-reload"],
  }
}
