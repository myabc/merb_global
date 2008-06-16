require 'spec_helper'

module Merb::Global::Providers
  def self.clear
    @@provider = nil
    @@providers = {}
  end
  def self.provider= provider
    @@provider = provider
  end
end

describe Merb::Global::Providers do
  before do
    Merb::Global::Providers.clear
  end
  describe '.provider' do
    it 'should return gettext as default' do
      provider = mock
      Merb::Global.expects(:config).with(:provider, 'gettext').
                   returns('gettext')
      Merb::Global::Providers.expects(:[]).with('gettext').returns(provider)
      Merb::Global::Providers.provider.should == provider
    end

    it 'should return the name of the provider in config' do
      provider = mock
      Merb::Global.expects(:config).with(:provider, 'gettext').returns('name')
      Merb::Global::Providers.expects(:[]).with('name').returns(provider)
      Merb::Global::Providers.provider.should == provider
    end

    it 'should return cached provider' do
      provider = mock
      Merb::Global::Providers.provider = provider
      Merb::Global::Providers.provider.should == provider
    end
  end
  describe '.[]' do
    it 'should load the provider' do
      provider = 'test'
      provider_path = 'merb_global/providers/test'
      Merb::Global::Providers.expects(:require).with(provider_path)
      Merb::Global::Providers.stubs(:eval)
      Merb::Global::Providers[provider]
    end

    it 'should create the provider' do
      provider = 'test'
      provider_class = 'Merb::Global::Providers::Test'
      Merb::Global::Providers.stubs(:require)
      Merb::Global::Providers.expects(:eval).with(provider_class + '.new')
      Merb::Global::Providers[provider]
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
