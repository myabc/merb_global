# -*- coding: utf-8 -*-
require 'spec_helper'
require 'merb_global/message_providers/yaml'

class Merb::Global::MessageProviders::Yaml
  attr_reader :lang
end

describe Merb::Global::MessageProviders::Yaml do
  before do
    @provider = Merb::Global::MessageProviders::Yaml.new
  end

  describe '.localize' do
    it 'should mark nil if file do not exists' do
      fr = Merb::Global::Locale.new('fr')
      @provider.localize 'Test', 'Tests', 2, fr
      @provider.lang.should include({fr => nil})
      @provider.lang[fr].should be_nil
    end

    it 'should check appropiete form' do
      pl = Merb::Global::Locale.new('pl')
      translated = @provider.localize 'Test', 'Tests', 2, pl
      translated.should == 'Testy'
    end

    it 'should translate for singular only also' do
      pl = Merb::Global::Locale.new('pl')
      trans = @provider.localize('Hello', nil, 1, pl)
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
