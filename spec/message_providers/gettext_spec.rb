require 'spec_helper'

if HAS_GETTEXT

  require 'merb_global/message_providers/gettext'

  describe Merb::Global::MessageProviders::Gettext do
    before do
      @provider = Merb::Global::MessageProviders::Gettext.new
    end

    describe '.create!' do
      it 'should create directory' do
        File.expects(:mkdirs).with(Merb::Global::MessageProviders.localedir)
        @provider.create!
      end
    end

    describe '.support?' do
      it 'should return true if directory exists' do
        @provider.support?('pl').should == true
      end

      it 'should return false otherwise' do
        @provider.support?('fr').should == false
      end
    end

    describe '.translate_to' do
      it 'should translate the string' do
        trans = @provider.translate_to 'Test', 'Tests', :n => 1, :lang => 'pl'
        trans.should == 'Test'
        trans = @provider.translate_to 'Test', 'Tests', :n => 2, :lang => 'pl'
        trans.should == 'Testy'
        trans = @provider.translate_to 'Test', 'Tests', :n => 5, :lang => 'pl'
        trans.should == 'Testów'
      end

      it 'should fallback if not present' do
        trans = @provider.translate_to 'Car', 'Cars', :n => 1, :lang => 'pl'
        trans.should == 'Car'
        trans = @provider.translate_to 'Car', 'Cars', :n => 2, :lang => 'pl'
        trans.should == 'Cars'
      end

      it 'should fallback if language is not supported' do
        trans = @provider.translate_to 'Test', 'Tests', :n => 1, :lang => 'fr'
        trans.should == 'Test'
        trans = @provider.translate_to 'Test', 'Tests', :n => 2, :lang => 'fr'
        trans.should == 'Tests'
      end

      it 'should translate for singular only also' do
        trans = @provider.translate_to('Hello', nil, :n => 1, :lang => 'pl')
        trans.should == 'Cześć'
      end
    end

    describe '.choose' do
      it 'should choose first language if given list is empty' do
        @provider.choose([]).should == 'pl'
      end

      it 'should choose first language not from list' do
        @provider.choose(['en', 'pl']).should be_nil
      end
    end

    describe '.import' do
      it 'should put data in the hash'
    end

    describe '.export' do
      it 'should transform data from hash into the database'
    end
  end
end
