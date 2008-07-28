require 'spec_helper'

module TestProviders
  include Merb::Global::Providers
  
  def self.clear
    @@provider = nil
    @@providers = {}
    @@providers_classes = {}
  end
end

describe Merb::Global::Providers do
  after do
    TestProviders.clear
  end
  
  describe '.[]' do
    it 'should lookup classes' do
      
    end
    
    it 'should load the provider' do
      provider = 'test'
      provider_path = 'merb_global/test_providers/test'
      TestProviders.expects(:require).with(provider_path)
      TestProviders.stubs(:eval)
      TestProviders[provider]
    end

    it 'should create the provider' do
      provider = 'test'
      provider_class = 'TestProviders::Test'
      TestProviders.stubs(:require)
      TestProviders.expects(:eval).with(provider_class + '.new')
      TestProviders[provider]
    end
  end
  
  describe '.register' do
    it 'should add the provider to hash'
  end
end

