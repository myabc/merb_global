require 'spec_helper'

class TestController < Merb::Controller
  def index
    'index'
  end
end

class FrTestController < Merb::Controller
  language {'fr'}
  def index
    "index"
  end
end

class SettableTestController < Merb::Controller
  attr_accessor :current_lang
  language {@current_lang}
  def index
    'index'
  end
end

describe Merb::Controller do
  it 'should set language to english by default' do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env.delete 'HTTP_ACCEPT_LANGUAGE'
    end
    controller.lang.should == 'en'
  end

  it 'should set language according to the preferences' do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
      controller.message_provider = provider = stub(:support? => true)
    end
    controller.lang.should == 'fr'
  end

  it 'should take the weights into account' do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] =
        'de;q=0.8,en;q=1.0,es;q=0.6'
      controller.message_provider = mock 'provider' do |provider|
        provider.expects(:support?).with('de').returns(true)
        provider.expects(:support?).with('en').returns(false)
        provider.stubs(:support?).with('es').returns(true)
      end
    end
    controller.lang.should == 'de'
  end

  it 'should assume 1.0 as default weight' do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'it,en;q=0.7'
      provider = controller.message_provider = stub(:support? => true)
    end
    controller.lang.should == 'it'
  end

  it 'should choose language if \'*\' given' do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = '*,en;q=0.7'
      provider = controller.message_provider = stub(:support? => true)
      provider.stubs(:support?).with('en').returns(true)
      provider.expects(:choose).with(['en']).returns('fr')
    end
    controller.lang.should == 'fr'
  end

  it "should have overriden settings by language block" do
    controller = dispatch_to(FrTestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'en'
    end
    controller.lang.should == 'fr'
  end

  it 'should evaluate in the object context' do
    controller = dispatch_to(SettableTestController, :index) do |controller|
      controller.current_lang = 'fr'
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'en'
    end
    controller.lang.should == 'fr'
  end

  it 'should fallback to lang if lang_REGION is not supported' do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'es-ES,pt-BR;q=0.7'
      provider = controller.message_provider = mock
      provider.expects(:support?).with('es-ES').returns(false)
      provider.expects(:support?).with('es').returns(false)
      provider.expects(:support?).with('pt-BR').returns(false)
      provider.expects(:support?).with('pt').returns(true)
    end
    controller.lang.should == 'pt'
  end
end
