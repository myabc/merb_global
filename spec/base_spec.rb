require 'spec_helper'

class TestBase
  include Merb::Global
end

describe Merb::Global do
  describe '.lang' do
    it 'should return \'en\' by default' do
      TestBase.new.lang.should == 'en'
    end

    it 'should return the setted language' do
      test_base = TestBase.new
      test_base.lang = lang = mock('lang')
      test_base.lang.should == lang
    end
  end

  describe '.message_provider' do
    it 'should return the default provider' do
      provider = mock 'provider'
      Merb::Global::MessageProviders.expects(:provider).returns(provider)
      TestBase.new.message_provider.should == provider
    end
  end
  
  describe '.date_provider' do
    it 'should return the default provider' do
      provider = mock 'provider'
      Merb::Global::DateProviders.expects(:provider).returns(provider)
      TestBase.new.date_provider.should == provider
    end
  end
  
  describe '.numeric_provider' do
    it 'should return the default provider' do
      provider = mock 'provider'
      Merb::Global::NumericProviders.expects(:provider).returns(provider)
      TestBase.new.numeric_provider.should == provider
    end
  end
  

  describe '._' do
    it 'should send singular and nil if plural not given' do
      test_base = TestBase.new
      test_base.message_provider = mock do |provider|
        expected_args = ['a', nil, {:n => 1, :lang => 'en'}]
        provider.expects(:translate_to).with(*expected_args).returns('b')
      end
      test_base._('a').should == 'b'
    end

    it 'should send singular and plural if both given' do
      test_base = TestBase.new
      test_base.message_provider = mock do |provider|
        expected_args = ['a', 'b', {:n => 1, :lang => 'en'}]
        provider.expects(:translate_to).with(*expected_args).returns('a')
      end
      test_base._('a', 'b').should == 'a'
    end

    it 'should send the proper number if given' do
      test_base = TestBase.new
      test_base.message_provider = mock do |provider|
        expected_args = ['a', 'b', {:n => 2, :lang => 'en'}]
        provider.expects(:translate_to).with(*expected_args).returns('b')
      end
      test_base._('a', 'b', :n => 2).should == 'b'
    end

    it 'should raise ArgumentException for wrong number of arguments' do
      lambda {TestBase.new._}.should raise_error(ArgumentError)
      lambda {TestBase.new._ 'a', 'b', 'c'}.should raise_error(ArgumentError)
    end
  end
end
