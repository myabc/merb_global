# -*- coding: utf-8 -*-
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

    describe '.localize' do
      it 'should translate the string' do
        pl = Merb::Global::Locale.new('pl')
        trans = @provider.localize 'Test', 'Tests', 1, pl
        trans.should == 'Test'
        trans = @provider.localize 'Test', 'Tests', 2, pl
        trans.should == 'Testy'
        trans = @provider.localize 'Test', 'Tests', 5, pl
        trans.should == 'Testów'
      end

      it 'should fallback if not present' do
        pl = Merb::Global::Locale.new('pl')
        trans = @provider.localize 'Car', 'Cars', 1, pl
        trans.should == 'Car'
        trans = @provider.localize 'Car', 'Cars', 2, pl
        trans.should == 'Cars'
      end

      it 'should fallback if language is not supported' do
        fr = Merb::Global::Locale.new('fr')
        trans = @provider.localize 'Test', 'Tests', 1, fr
        trans.should == 'Test'
        trans = @provider.localize 'Test', 'Tests', 2, fr
        trans.should == 'Tests'
      end

      it 'should translate for singular only also' do
        pl = Merb::Global::Locale.new('pl')
        trans = @provider.localize('Hello', nil, 1, pl)
        trans.should == 'Cześć'
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
