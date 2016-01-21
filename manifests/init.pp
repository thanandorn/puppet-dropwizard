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
  $config_path    = $::dropwizard::params::config_path,
  $sysconfig_path = $::dropwizard::params::sysconfig_path,
  $base_path      = $::dropwizard::params::base_path,
  $run_user       = $::dropwizard::params::run_user,
  $run_group      = $::dropwizard::params::run_group,
  $config_mode    = $::dropwizard::params::config_mode,
  $instances      = {},
) inherits dropwizard::params {

  include ::java
  contain ::java

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

  create_resources('dropwizard::instance', $instances,
    { require => Class['::java'] } )
}
