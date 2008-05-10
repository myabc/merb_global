require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class TestController < Merb::Controller
  def index
    "index"
  end
end

describe Merb::Controller do
  it "should set language to english by default" do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env.delete 'HTTP_ACCEPT_LANGUAGE'
    end
    controller.lang.should == 'en'
  end
  it "should set language according to the preferences" do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
      provider = controller.provider = mock('provider')
      provider.stub!(:supported?).and_return(true)
    end
    controller.lang.should == 'fr'
  end
  it "should take the weights into account" do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] =
        'de;q=0.8,en;q=1.0,es;q=0.6'
      provider = controller.provider = mock('provider')
      provider.stub!(:supported?).and_return(true, true, false)
    end
    controller.lang.should == 'de'
  end
  it "should assume 1.0 as default weight" do
    controller = dispatch_to(TestController, :index) do |controller|
      controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'it,en;q=0.7'
      provider = controller.provider = mock('provider')
      provider.stub!(:supported?).and_return(true)
    end
    controller.lang.should == 'it'
  end
end

