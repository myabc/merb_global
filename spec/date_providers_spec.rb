require 'spec_helper'

class TestDateProvider
  include Merb::Global::DateProviders::Base
end

module Merb::Global::DateProviders
  def self.clear
    @@provider = nil
    @@providers = {}
    @@providers_classes = {}
  end
  def self.provider= provider
    @@provider = provider
  end
end

describe Merb::Global::DateProviders do
  before do
    Merb::Global::DateProviders.clear
  end
  describe '.provider' do
    it 'should return fork as default' do
      provider = mock
      Merb::Global.expects(:config).with(:date_provider, 'fork').
                   returns('fork')
      Merb::Global::DateProviders.expects(:[]).with('fork').returns(provider)
      Merb::Global::DateProviders.provider.should == provider
    end

    it 'should return the name of the provider in config' do
      provider = mock
      Merb::Global.expects(:config).with(:date_provider, 'fork').
                   returns('name')
      Merb::Global::DateProviders.expects(:[]).with('name').
                                     returns(provider)
      Merb::Global::DateProviders.provider.should == provider
    end

    it 'should return cached provider' do
      provider = mock
      Merb::Global::DateProviders.provider = provider
      Merb::Global::DateProviders.provider.should == provider
    end
  end
end

describe Merb::Global::DateProviders::Base do
  before do
    @provider = TestDateProvider.new
  end

  describe '.localize' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.localize 'en', Date.new, '%A'
      end.should raise_error(NoMethodError)
    end
  end
end

describe 'Merb::Global.DateProvider' do
  it 'should create a module' do
    mod = Module.new
    Module.expects(:new).returns(mod)
    Merb::Global.DateProvider(:test).should == mod
  end
  
  it 'should include base only' do
    Module.any_instance.expects(:include).
                        with(Merb::Global::DateProviders::Base)
    Merb::Global.DateProvider(:test1)
  end

  it 'should register when include' do
    klass = Class.new
    Merb::Global::DateProviders.expects(:register).with(:test2, klass)
    klass.instance_eval do
      include Merb::Global.DateProvider(:test2)
    end
  end
end
