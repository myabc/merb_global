require 'spec_helper'

module TestProviders
  include Merb::Global::Providers
  
  def self.providers_classes
    @@providers_classes
  end
  
  def self.providers_classes=(providers_classes)
    @@providers_classes = providers_classes
  end
  
  def self.clear
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
      provider = mock
      provider_klass = mock do |klass|
        klass.expects(:new).returns(provider)
      end
      TestProviders.providers_classes = {:test => provider_klass}
      TestProviders[:test].should == provider
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
    it 'should add the provider to hash' do
      provider_class = mock
      TestProviders.register(:test, provider_class)
      TestProviders.providers_classes.should == {:test => provider_class}
    end
  end
end

