# == Class: dropwizard
#
# Full description of class dropwizard here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the function of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'dropwizard':
#    config_path = '/etc/dropwizard',
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
  $java_distribution     = $::dropwizard::params::java_distribution,
  $java_package          = $::dropwizard::params::java_package,
  $java_version          = $::dropwizard::params::java_version,
  $java_alternative      = $::dropwizard::params::java_alternative,
  $java_alternative_path = $::dropwizard::params::java_alternative_path,
  $run_user              = $::dropwizard::params::run_user,
  $run_group             = $::dropwizard::params::run_group,
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

  class { '::nginx':
    pid            => '/run/nginx.pid',
    service_ensure => running,
  }
  contain ::nginx

}
