require 'spec_helper'
describe 'dropwizard' do

  context 'with defaults for all parameters' do
    it { should contain_class('dropwizard') }
  end
end
