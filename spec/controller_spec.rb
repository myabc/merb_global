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
    Merb::Global::Locale.current.should == Merb::Global::Locale.new('en')
  end

  it 'should set language according to the preferences' do
    Merb::Global::Locale.stubs(:support?).returns(true)
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
    end
    Merb::Global::Locale.current.should == Merb::Global::Locale.new('fr')
  end

  it 'should take the weights into account' do
    de = Merb::Global::Locale.new('de')
    Merb::Global.stubs(:config).with('locales', ['en']).returns(['de', 'es'])
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] =
        'de;q=0.8,en;q=1.0,es;q=0.6'
    end
    Merb::Global::Locale.current.should == de
  end

  it 'should assume 1.0 as default weight' do
    it = Merb::Global::Locale.new('it')
    Merb::Global::Locale.stubs(:support?).returns(true)
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'it,en;q=0.7'
    end
    Merb::Global::Locale.current.should == it
  end

  it 'should choose language if \'*\' given' do
    fr = Merb::Global::Locale.new('fr')
    en = Merb::Global::Locale.new('en')
    Merb::Global.stubs(:config).with('locales', ['en']).returns(['en','fr'])
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = '*,en;q=0.7'
    end
    Merb::Global::Locale.current.should == fr
  end

  it "should have overriden settings by language block" do
    en = Merb::Global::Locale.new('en')
    fr = Merb::Global::Locale.new('fr')
    controller = dispatch_to(FrTestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'en'
    end
    Merb::Global::Locale.current.should == fr
  end

  it 'should evaluate in the object context' do
    fr = Merb::Global::Locale.new('fr')
    controller = dispatch_to(SettableTestController, :index) do |controller|
      controller.current_lang = 'fr'
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'en'
    end
    Merb::Global::Locale.current.should == fr
  end

  it 'should fallback to lang if lang_REGION is not supported' do
    pt = Merb::Global::Locale.new('pt')
    Merb::Global.stubs(:config).with('locales', ['en']).returns(['pt'])    
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'es-ES,pt-BR;q=0.7'
    end
    Merb::Global::Locale.current.should == pt
  end
end
