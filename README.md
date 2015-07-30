# puppet-dropwizard

#### Table of Contents

1. [Overview](#overview)
2. [Limitations - OS compatibility, etc.](#limitations)
3. [Setup - The basics of getting started with dropwizard](#setup)
    * [Module Installation](#module-installation)
4. [Usage - Configuration options and additional functionality](#usage)

## Overview

Puppet module for installing, configuring and managing [Dropwizard](https://www.dropwizard.io) application.

## Limitations

Supported Systems
* CentOS 7 (systemd)

Supported Config Type
* YAML


## Setup

### Module Installation

To install the module run:

```
 $ puppet module install thanandorn-dropwizard
```

Or install via `librarian-puppet`. Add below to `Pupppetfile`

```
mod 'thanandorn-dropwizard'
```

## Usage

By default, the module will install Java from default values of [puppetlabs-java](https://github.com/puppetlabs/puppetlabs-java) and Nginx from [jfryman-nginx](https://github.com/jfryman/puppet-nginx)

```puppet
  include ::dropwizard
```

To install specific Java package and version

```puppet
  class { '::dropwizard':
    java_package => 'jdk',
    java_version => '1.8.0_51',
  }
```
To create Dropwizard config files and services

```puppet
  class { '::dropwizard':
    java_package => 'jdk',
    java_version => '1.8.0_51',
    instances    => {
      "demoapp"  => {
        http_port   => "8080",
        config_hash => {
          "server"  => {
            'type'             => 'simple',
            'appContextPath'   => '/app',
            'adminContextPath' => '/admin',
            'connector'        => {
              'type' => 'http',
              'port' => '8080'
            }
          }
        }
      }
    }
```

To create Dropwizard config files and services from `hiera`

```
---
classes:
  - dropwizard

dropwizard::java_package: 'jdk'
dropwizard::java_version: '1.8.0_51'
dropwizard::instances:
  demoapp:
    http_port: 8080
    server:
      type: 'simple'
      appContextPath: '/app'
      adminContextPath: '/admin'
      connector:
        type: 'http'
        port: 8080
```

