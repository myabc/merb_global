require 'spec_helper'

class Provider
  include Merb::Global::MessageProviders::Base
end

module Merb::Global::MessageProviders
  def self.clear
    @@provider = nil
    @@providers = {}
  end
  def self.provider= provider
    @@provider = provider
  end
end

describe Merb::Global::MessageProviders do
  before do
    Merb::Global::MessageProviders.clear
  end
  describe '.provider' do
    it 'should return gettext as default' do
      provider = mock
      Merb::Global.expects(:config).with(:message_provider, 'gettext').
                   returns('gettext')
      Merb::Global::MessageProviders.expects(:[]).with('gettext').returns(provider)
      Merb::Global::MessageProviders.provider.should == provider
    end

    it 'should return the name of the provider in config' do
      provider = mock
      Merb::Global.expects(:config).with(:message_provider, 'gettext').
                   returns('name')
      Merb::Global::MessageProviders.expects(:[]).with('name').
                                     returns(provider)
      Merb::Global::MessageProviders.provider.should == provider
    end

    it 'should return cached provider' do
      provider = mock
      Merb::Global::MessageProviders.provider = provider
      Merb::Global::MessageProviders.provider.should == provider
    end
  end
  describe '.[]' do
    it 'should lookup classes'
    it 'should load the provider' do
      provider = 'test'
      provider_path = 'merb_global/message_providers/test'
      Merb::Global::MessageProviders.expects(:require).with(provider_path)
      Merb::Global::MessageProviders.stubs(:eval)
      Merb::Global::MessageProviders[provider]
    end

    it 'should create the provider' do
      provider = 'test'
      provider_class = 'Merb::Global::MessageProviders::Test'
      Merb::Global::MessageProviders.stubs(:require)
      Merb::Global::MessageProviders.expects(:eval).with(provider_class + '.new')
      Merb::Global::MessageProviders[provider]
    end
  end

  describe '.localedir' do
    it 'should return app/locale by default' do
      Merb::Plugins.stubs(:config).returns({})
      expected = File.join Merb.root, 'app', 'locale'
      Merb::Global::MessageProviders.localedir.should == expected
    end

    it 'should return locale when flat option setted' do
      Merb::Plugins.stubs(:config).returns({:merb_global => {:flat => true}})
      expected = File.join Merb.root, 'locale'
      Merb::Global::MessageProviders.localedir.should == expected
    end

    it 'should return user setted path' do
      config = {:merb_global => {:localedir => 'test'}}
      Merb::Plugins.stubs(:config).returns(config)
      expected = File.join Merb.root, 'test'
      Merb::Global::MessageProviders.localedir.should == expected
    end
  end
end

describe Merb::Global::MessageProviders::Base do
  before do
    @provider = Provider.new
  end

  describe '.translate_to' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.translate_to 'test', 'tests', :n => 1, :lang => 'en'
      end.should raise_error(NoMethodError)
    end
  end

  describe '.support?' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.support? 'en'
      end.should raise_error(NoMethodError)
    end
  end

  describe '.create!' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.create!
      end.should raise_error(NoMethodError)
    end
  end

  describe '.choose' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.choose ['en']
      end.should raise_error(NoMethodError)
    end
  end
end
