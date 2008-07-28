require 'spec_helper'
require 'stringio'

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

    describe '.localize' do
      it 'should translate the string' do
        trans = @provider.localize 'Test', 'Tests', :n => 1, :lang => 'pl'
        trans.should == 'Test'
        trans = @provider.localize 'Test', 'Tests', :n => 2, :lang => 'pl'
        trans.should == 'Testy'
        trans = @provider.localize 'Test', 'Tests', :n => 5, :lang => 'pl'
        trans.should == 'Testów'
      end

      it 'should fallback if not present' do
        trans = @provider.localize 'Car', 'Cars', :n => 1, :lang => 'pl'
        trans.should == 'Car'
        trans = @provider.localize 'Car', 'Cars', :n => 2, :lang => 'pl'
        trans.should == 'Cars'
      end

      it 'should fallback if language is not supported' do
        trans = @provider.localize 'Test', 'Tests', :n => 1, :lang => 'fr'
        trans.should == 'Test'
        trans = @provider.localize 'Test', 'Tests', :n => 2, :lang => 'fr'
        trans.should == 'Tests'
      end

      it 'should translate for singular only also' do
        trans = @provider.localize('Hello', nil, :n => 1, :lang => 'pl')
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
      it 'should put data in the hash' do
        @provider.import.should == {
          "pl" => {
            :plural => "(n==1?0:n%10>=2&&n%10<=4&&(n%100<10||n%100>=20)?1:2)",
            :nplural => 3,
            "Hello" => {:plural => nil, nil => "Cześć"},
            "Test" => {
              :plural => "Tests",
              0 => "Test",
              1 => "Testy",
              2 => "Testów"
            }
          }
        }
      end
    end

    describe '.export' do
      it 'should transform data from hash into po files'
    end
  end
end
