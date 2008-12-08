require 'spec_helper'
require 'merb_global/message_providers/mock'

describe Merb::Global::MessageProviders::Mock do
  before do
    @provider = Merb::Global::MessageProviders::Mock.new
  end

  describe '.localize' do
    it 'should return plural for n > 1' do
      pl = Merb::Global::Locale.new(pl)
      @provider.localize('test', 'tests', 2, pl).should == 'tests'
    end

    it 'should return singular for n <= 1' do
      pl = Merb::Global::Locale.new(pl)
      @provider.localize('test', 'tests', 0, pl).should == 'test'
      @provider.localize('test', 'tests', 1, pl).should == 'test'
    end
  end

  describe '.create!' do
    it 'should do nothing' do
      @provider.create!.should be_nil
    end
  end
end
