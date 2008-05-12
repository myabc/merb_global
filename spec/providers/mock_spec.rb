require 'spec_helper'

describe Merb::Global::Providers::Mock do
  before do
    @provider = Merb::Global::Providers::Mock.new
  end
  describe '.translate_to' do
    it 'should return plural for n > 1' do
      @provider.translate_to("test", "tests", :n => 2).should == "tests"
    end
    it 'should return singular for n <= 1' do
      @provider.translate_to("test", "tests", :n => 0).should == "test"
      @provider.translate_to("test", "tests", :n => 1).should == "test"
    end
  end
  describe '.support?' do
    it 'should return true' do
      @provider.support?(mock) == true
    end
  end
  describe '.create!' do
    it 'should do nothing' do
      @provider.create!.should be_nil
    end
  end
end
