require 'spec_helper'

class TestBase
  include Merb::Global
end

describe Merb::Global do
  describe ".lang" do
    it "should return 'en' by default" do
      TestBase.new.lang.should == 'en'
    end
    it "should return the setted language" do
      test_base = TestBase.new
      test_base.lang = lang = mock("lang")
      test_base.lang.should == lang
    end
  end
  describe ".provider" do
    it "should return the default provider" do
      provider = mock "provider"
      Merb::Global::Providers.expects(:provider).returns(provider)
      TestBase.new.provider.should == provider
    end
  end
  describe "._" do
    it "should send doubled singular if plural not given" do
      test_base = TestBase.new
      test_base.provider = mock do |provider|
        expected_args = ["a", "a", {:n => 1, :lang => "en"}]
        provider.expects(:translate_to).with(*expected_args).returns("b")
      end
      test_base._("a").should == "b"
    end
    it "should send singular and plural if both given" do
      test_base = TestBase.new
      test_base.provider = mock do |provider|
        expected_args = ["a", "b", {:n => 1, :lang => "en"}]
        provider.expects(:translate_to).with(*expected_args).returns("a")
      end
      test_base._("a", "b").should == "a"
    end
    it "should send the proper number if given" do
      test_base = TestBase.new
      test_base.provider = mock do |provider|
        expected_args = ["a", "b", {:n => 2, :lang => "en"}]
        provider.expects(:translate_to).with(*expected_args).returns("b")
      end
      test_base._("a", "b", :n => 2).should == "b"
    end
  end
end
