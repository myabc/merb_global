require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class Test < Merb::Controller
  def index
    "index"
  end
end

describe Merb::Controller do
  it "should set the language on request" do
    controller = dispatch_to(Test, :index)
  end
end
