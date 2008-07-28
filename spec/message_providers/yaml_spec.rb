require 'spec_helper'
require 'merb_global/message_providers/yaml'

class Merb::Global::MessageProviders::Yaml
  attr_reader :lang
end

describe Merb::Global::MessageProviders::Yaml do
  before do
    @provider = Merb::Global::MessageProviders::Yaml.new
  end

  describe '._support?' do
    it 'should return true if file exists' do
      @provider.support?('pl').should == true
    end

    it 'should return false if file doesn\'t exist' do
      @provider.support?('fr').should == false
    end
  end

  describe '.localize' do
    it 'should mark nil if file do not exists' do
      @provider.localize 'Test', 'Tests', :lang => 'fr', :n => 1
      @provider.lang.should include('fr')
      @provider.lang['fr'].should be_nil
    end

    it 'should check appropiete form' do
      translated = @provider.localize 'Test', 'Tests',
                                          :lang => 'pl', :n => 2
      translated.should == 'Testy'
    end

    it 'should translate for singular only also' do
      trans = @provider.localize('Hello', nil, :n => 1, :lang => 'pl')
      trans.should == 'Cześć'
    end
  end

  describe '.create!' do
    it 'should create app/locale firectory' do
      file = Merb::Global::MessageProviders.localedir
      FileUtils.expects(:mkdir_p).with(file)
      @provider.create!
    end
  end

  describe '.choose' do
    it 'should choose first language if given list is empty' do
      @provider.choose([]).should == 'pl'
    end

    it 'should choose first language not from list' do
      @provider.choose(['pl']).should be_nil
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
    it 'should put the data in files'
  end
end
