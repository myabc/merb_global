require 'spec_helper'
require 'merb_global/providers/yaml'

class Merb::Global::Providers::Yaml
  attr_reader :lang
end

describe Merb::Global::Providers::Yaml do
  before do
    @provider = Merb::Global::Providers::Yaml.new
  end

  describe '._support?' do
    it 'should return true if file exists' do
      @provider.support?('pl').should == true
    end

    it 'should return false if file doesn\'t exist' do
      @provider.support?('fr').should == false
    end
  end

  describe '.translate_to' do
    it 'should mark nil if file do not exists' do
      @provider.translate_to 'Test', 'Tests', :lang => 'fr', :n => 1
      @provider.lang.should include('fr')
      @provider.lang['fr'].should be_nil
    end

    it 'should check appropiete form' do
      translated = @provider.translate_to 'Test', 'Tests',
                                          :lang => 'pl', :n => 2
      translated.should == 'Testy'
    end

    it 'should translate for singular only also' do
      trans = @provider.translate_to('Hello', nil, :n => 1, :lang => 'pl')
      trans.should == 'Cześć'
    end
  end

  describe '.create!' do
    it 'should create app/locale firectory' do
      file = Merb::Global::Providers.localedir
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
    it 'should iterate over the translations'
  end

  describe '.export' do
    it 'should put the data in files'
  end
end
