# == Class: dropwizard
#
# Puppet module for installing, configuring and managing Dropwizard application.
#
# === Parameters
#
# === Variables
#
#
# === Examples
#
#
#
#  class { '::dropwizard':
#    java_package => 'jdk',
#    java_version => '1.8.0_51',
#  }
#
# === Authors
#
# Tron Thongsringklee <thanandorn@gmail.com>
#
# === Copyright
#
# Copyright 2015 Tron Thongsringklee.
#
class dropwizard (
  $config_path           = $::dropwizard::params::config_path,
  $base_path             = $::dropwizard::params::base_path,
  $java_distribution     = $::dropwizard::params::java_distribution,
  $java_package          = $::dropwizard::params::java_package,
  $java_version          = $::dropwizard::params::java_version,
  $java_alternative      = $::dropwizard::params::java_alternative,
  $java_alternative_path = $::dropwizard::params::java_alternative_path,
  $run_user              = $::dropwizard::params::run_user,
  $run_group             = $::dropwizard::params::run_group,
  $proxy                 = $::dropwizard::params::proxy,
  $virtual_hosts         = $::dropwizard::params::virtual_hosts,
  $location_defaults     = $::dropwizard::params::location_defaults,
  $instances             = {},
) inherits dropwizard::params {

  if ! defined(User[$run_user]) {
    user { $run_user:
      ensure => present,
      system => true,
    }
  }

  if ! defined(Group[$run_group]) {
    group { $run_group:
      ensure => present,
      system => true,
    }
  }

  if ! defined(File[$config_path]) {
    file { $config_path:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  class { '::java':
    distribution          => $java_distribution,
    package               => $java_package,
    version               => $java_version,
    java_alternative      => $java_alternative,
    java_alternative_path => $java_alternative_path,
  }
  contain ::java

  create_resources('dropwizard::instance', $instances,
    { require => Class['::java'] } )

  validate_bool($proxy)
  validate_hash($virtual_hosts)

  if $proxy {
    include ::nginx
    contain ::nginx
    create_resources('nginx::resource::vhost', $virtual_hosts)
  }
}
