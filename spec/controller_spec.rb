require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class Test < Merb::Controller
  def index
    "index"
  end
end

describe Merb::Controller do
  it "should set language to english by default" do
    controller = dispatch_to(Test, :index)
    controller.lang.should == "en"
  end
  it "should set language according to the preferences" do
    env = {'HTTP_ACCEPT_LANGUAGE' => 'fr'}
    controller = dispatch_to(Test, :index, env) do |controller|
      provider = controller.provider = mock('provider')
      provider.should_receive(:supported?).and_return(true)
    end
    controller.lang.should == "fr"
  end
end

