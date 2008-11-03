require 'spec_helper'

class TestMessageProvider
  include Merb::Global::MessageProviders::Base
end

module Merb::Global::MessageProviders
  def self.clear
    @@provider = nil
    @@providers = {}
    @@providers_classes = {}
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

  describe '.localedir' do
    it 'should return app/locale by default' do
      Merb::Global.expects(:config).with(:flat).returns(nil)
      Merb::Global.expects(:config).with(:localedir, 'app/locale').returns('app/locale')
      expected = File.join Merb.root, 'app', 'locale'
      Merb::Global::MessageProviders.localedir.should == expected
    end

    it 'should return locale when flat option setted' do
      Merb::Global.expects(:config).with(:flat).returns(nil)
      Merb::Global.expects(:config).with(:localedir, 'app/locale').returns('locale')
      expected = File.join Merb.root, 'locale'
      Merb::Global::MessageProviders.localedir.should == expected
    end

    it 'should return user setted path' do
      config = {:merb_global => {:localedir => 'test'}}
      Merb::Global.stubs(:config).returns(config)
      Merb::Global.stubs(:config).with(:flat).returns(nil)
      Merb::Global.expects(:config).with(:localedir, 'app/locale').returns('test')
      expected = File.join Merb.root, 'test'
      Merb::Global::MessageProviders.localedir.should == expected
    end
  end
end

describe Merb::Global::MessageProviders::Base do
  before do
    @provider = TestMessageProvider.new
  end

  describe '.localize' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.localize 'test', 'tests', 1, Merb::Global::Locale.new('en')
      end.should raise_error(NoMethodError)
    end
  end

  describe '.support?' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.support? Merb::Global::Locale.new('en')
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
        @provider.choose [Merb::Global::Locale.new('en')]
      end.should raise_error(NoMethodError)
    end
  end

  describe '.transfer' do
    it 'should transfer data' do
      data = mock
      importer = mock do |importer|
        importer.expects(:import).returns(data)
      end
      exporter = mock do |exporter|
        exporter.expects(:export).with(data)
      end
      Merb::Global::MessageProviders::Base.transfer importer, exporter
    end
  end
end

class MyImporter
  include Merb::Global::MessageProviders::Base
  include Merb::Global::MessageProviders::Base::Importer
end

describe Merb::Global::MessageProviders::Base::Importer do
  describe '.import' do
    it 'should raise error' do
      lambda {MyImporter.new.import}.should raise_error(NoMethodError)
    end
  end
end

class MyExporter
  include Merb::Global::MessageProviders::Base
  include Merb::Global::MessageProviders::Base::Exporter
end

describe Merb::Global::MessageProviders::Base::Exporter do
  describe '.export' do
    it 'should raise error' do
      lambda {MyExporter.new.export({})}.should raise_error(NoMethodError)
    end
  end
end

describe 'Merb::Global.MessageProvider' do
  it 'should create a module' do
    mod = Module.new
    Module.expects(:new).returns(mod)
    Merb::Global.MessageProvider(:test).should == mod
  end
  
  it 'should include base only' do
    Module.any_instance.expects(:include).
                        with(Merb::Global::MessageProviders::Base)
    Merb::Global.MessageProvider(:test1)
  end
  
  it 'should include importer if option given' do
    Module.any_instance.stubs(:include).
                        with(Merb::Global::MessageProviders::Base)
    Module.any_instance.expects(:include).
                        with(Merb::Global::MessageProviders::Base::Importer)
    Merb::Global.MessageProvider(:test2, :importer)
  end

  it 'should include exporter if option given' do
    Module.any_instance.stubs(:include).
                        with(Merb::Global::MessageProviders::Base)
    Module.any_instance.expects(:include).
                        with(Merb::Global::MessageProviders::Base::Exporter)
    Merb::Global.MessageProvider(:test3, :exporter)
  end

  it 'should register when include' do
    klass = Class.new
    Merb::Global::MessageProviders.expects(:register).with(:test4, klass)
    klass.instance_eval do
      include Merb::Global.MessageProvider(:test4)
    end
  end
end
