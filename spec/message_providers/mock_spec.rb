require 'spec_helper'
require 'merb_global/message_providers/mock'

describe Merb::Global::MessageProviders::Mock do
  before do
    @provider = Merb::Global::MessageProviders::Mock.new
  end

  describe '.localize' do
    it 'should return plural for n > 1' do
      @provider.localize('test', 'tests', :n => 2).should == 'tests'
    end

    it 'should return singular for n <= 1' do
      @provider.localize('test', 'tests', :n => 0).should == 'test'
      @provider.localize('test', 'tests', :n => 1).should == 'test'
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

  describe '.choose' do
    it 'should return \'en\'' do
      @provider.choose([]).should == 'en'
    end
  end
end
