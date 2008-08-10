require 'spec_helper'

class TestNumericProvider
  include Merb::Global::NumericProviders::Base
end

module Merb::Global::NumericProviders
  def self.clear
    @@provider = nil
    @@providers = {}
    @@providers_classes = {}
  end
  def self.provider= provider
    @@provider = provider
  end
end

describe Merb::Global::NumericProviders do
  before do
    Merb::Global::NumericProviders.clear
  end
  describe '.provider' do
    it 'should return fork as default' do
      provider = mock
      Merb::Global.expects(:config).with(:numeric_provider, 'fork').
                   returns('fork')
      Merb::Global::NumericProviders.expects(:[]).with('fork').returns(provider)
      Merb::Global::NumericProviders.provider.should == provider
    end

    it 'should return the name of the provider in config' do
      provider = mock
      Merb::Global.expects(:config).with(:numeric_provider, 'fork').
                   returns('name')
      Merb::Global::NumericProviders.expects(:[]).with('name').
                                     returns(provider)
      Merb::Global::NumericProviders.provider.should == provider
    end

    it 'should return cached provider' do
      provider = mock
      Merb::Global::NumericProviders.provider = provider
      Merb::Global::NumericProviders.provider.should == provider
    end
  end
end

describe Merb::Global::NumericProviders::Base do
  before do
    @provider = TestNumericProvider.new
  end

  describe '.localize' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.localize 'en', 1.0
      end.should raise_error(NoMethodError)
    end
  end
end

describe 'Merb::Global.NumericProvider' do
  it 'should create a module' do
    mod = Module.new
    Module.expects(:new).returns(mod)
    Merb::Global.NumericProvider(:test).should == mod
  end
  
  it 'should include base only' do
    Module.any_instance.expects(:include).
                        with(Merb::Global::NumericProviders::Base)
    Merb::Global.NumericProvider(:test1)
  end

  it 'should register when include' do
    klass = Class.new
    Merb::Global::NumericProviders.expects(:register).with(:test2, klass)
    klass.instance_eval do
      include Merb::Global.NumericProvider(:test2)
    end
  end
end
