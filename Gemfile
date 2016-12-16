source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 3.8']

group :test do
  gem 'rake'
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'puppet', puppetversion
  gem 'puppetlabs_spec_helper', '>= 0.8.2'
  gem 'puppet-lint', '>= 1.0.0'
  gem 'facter', '>= 1.7.0'
  gem 'metadata-json-lint'
  gem 'json_pure', "<= 1.8.3"
end
