require 'spec_helper'

module Merb::Global::Providers
  def self.provider_name
    @@provider_name
  end
  def self.provider_loading
    @@provider_loading
  end
  def self.provider= provider
    @@provider = provider
  end
end

describe Merb::Global::Providers do
  describe '.provider_name' do
    it 'should return gettext as default' do
      Merb::Plugins.expects(:config).returns({})
      Merb::Global::Providers.provider_name.call.should == 'gettext'
    end
    it 'should return the name of the provider in config' do
      provider = mock
      config = {:merb_global => {:provider => provider}}
      Merb::Plugins.expects(:config).returns(config).at_least_once
      Merb::Global::Providers.provider_name.call.should == provider
    end
  end
  describe '.provider_loading' do
    it 'should change the provider into correct form' do
      provider = mock do |provider|
        provider.expects(:gsub).with(/_/, '').returns("test")
        provider.stubs(:camel_case).returns("Test")
      end
      provider_path = 'merb_global/providers/test'
      Merb::Global::Providers.expects(:require).with(provider_path)
      Merb::Global::Providers.stubs(:eval)
      Merb::Global::Providers.provider_loading.call(provider)
    end
    it 'should load the provider' do
      provider = mock do |provider|
        provider.stubs(:gsub).with(/_/, '').returns("test")
        provider.expects(:camel_case).returns("Test")
      end
      provider_class = 'Merb::Global::Providers::Test'
      Merb::Global::Providers.stubs(:require)
      Merb::Global::Providers.expects(:eval).with(provider_class + '.new')
      Merb::Global::Providers.provider_loading.call(provider)
    end
  end
  describe '.provider' do
    before do
      @provider = Merb::Global::Providers.provider
    end
    after do
      Merb::Global::Providers.provider = @provider
    end
    it 'should return the provider' do
      provider = mock
      Merb::Global::Providers.provider = provider
      Merb::Global::Providers.provider.should == provider
    end
  end
  describe '.localedir' do
    it 'should return app/locale by default' do
      Merb::Plugins.stubs(:config).returns({})
      expected = File.join Merb.root, 'app', 'locale'
      Merb::Global::Providers.localedir.should == expected
    end
    it 'should return locale when flat option setted' do
      Merb::Plugins.stubs(:config).returns({:merb_global => {:flat => true}})
      expected = File.join Merb.root, 'locale'
      Merb::Global::Providers.localedir.should == expected
    end
    it 'should return user setted path' do
      config = {:merb_global => {:localedir => 'test'}}
      Merb::Plugins.stubs(:config).returns(config)
      expected = File.join Merb.root, 'test'
      Merb::Global::Providers.localedir.should == expected
    end
  end
end
