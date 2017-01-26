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
  $base_path      = $::dropwizard::params::base_path,
  $config_path    = $::dropwizard::params::config_path,
  $config_mode    = $::dropwizard::params::config_mode,
  $sysconfig_path = $::dropwizard::params::sysconfig_path,
  $run_user       = $::dropwizard::params::run_user,
  $run_uid        = $::dropwizard::params::run_uid,
  $run_group      = $::dropwizard::params::run_group,
  $run_gid        = $::dropwizard::params::run_gid,
  $instances      = {},
) inherits dropwizard::params {

  include ::java
  contain ::java

  if ! defined(User[$run_user]) {
    user { $run_user:
      ensure => present,
      system => true,
      uid    => $run_uid,
    }
  }

  if ! defined(Group[$run_group]) {
    group { $run_group:
      ensure => present,
      system => true,
      gid    => $run_gid,
    }
  }

  if ! defined(File[$config_path]) {
    file { $config_path:
      ensure => directory,
      owner  => $run_user,
      group  => $run_group,
      mode   => '0755',
      before => Class['::java'],
    }
  }

  create_resources('dropwizard::instance', $instances,
    { require => Class['::java'] } )
}
