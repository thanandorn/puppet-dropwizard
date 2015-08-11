# puppet-dropwizard

[![Build Status](https://travis-ci.org/thanandorn/puppet-dropwizard.svg?branch=master)](https://travis-ci.org/thanandorn/puppet-dropwizard)

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

```bash
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

To create Dropwizard config files and services

```puppet
  class { '::dropwizard':
    instances    => {
      'demoapp'  => {
        config_hash => {
          "server"  => {
            'type'           => 'simple',
            'appContextPath' => '/app',
            'connector'      => {
              'type' => 'http',
              'port' => '8080'
            }
          }
        }
      }
    }
```

To create Dropwizard config files and services from `hiera`

```yaml
---
classes:
  - dropwizard

java::package: 'jdk'
java::version: '1.8.0_51'

dropwizard::instances:
  demoapp:
    config_hash:
      server:
        type: 'simple'
        appContextPath: '/app'
        connector:
          type: 'http'
          port: 8080
```

