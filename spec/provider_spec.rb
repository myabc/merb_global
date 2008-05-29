require 'spec_helper'

describe Merb::Global::Provider do
  before do
    @provider = Merb::Global::Provider.new
  end

  describe '.translate_to' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.translate_to 'test', 'tests', :n => 1, :lang => 'en'
      end.should raise_error(NoMethodError)
    end
  end

  describe '.support?' do
    it 'should raise NoMethodError' do
      lambda do
        @provider.support? 'en'
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
        @provider.choose ['en']
      end.should raise_error(NoMethodError)
    end
  end
end
