require 'spec_helper'

if HAS_DM
  require 'data_mapper'

  DataMapper.setup :default, 'sqlite3::memory:'

  require 'merb_global/message_providers/data_mapper'

  describe Merb::Global::MessageProviders::DataMapper do
    before do
      @provider = Merb::Global::MessageProviders::DataMapper.new
      # Quick'n'dirty hack - to change in future
      @provider.create!
    end

    describe '.create!' do
      it 'should call automigrate' do
        lambda {@provider.create!}.should_not raise_error
      end
    end

    describe '.support?' do
      before do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        lang.create! :name => 'en', :plural => 'n==1?1:0'
      end

      it 'should return true for language in database' do
        @provider.support?('en').should == true
      end

      it 'should return false otherwise' do
        @provider.support?('fr').should == false
      end
    end

    describe '.translate_to' do
      before do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        en = lang.create! :name => 'en', :plural => 'n==1?0:1'
        trans = Merb::Global::MessageProviders::DataMapper::Translation
        trans.create! :language_id => en.id,
                      :msgid => 'Test', :msgid_plural => 'Tests',
                      :msgstr => 'One test', :msgstr_index => 0
        trans.create! :language_id => en.id,
                      :msgid => 'Test', :msgid_plural => 'Tests',
                      :msgstr => 'Many tests', :msgstr_index => 1
      end

      it 'should fetch the correct translation from database if avaible' do
        trans = @provider.translate_to('Test', 'Tests', :lang => 'en', :n => 1)
        trans.should == 'One test'
      end

      it 'should fallback to default if needed' do
        trans = @provider.translate_to('Test', 'Tests', :lang => 'fr', :n => 2)
        trans.should == 'Tests'
      end
    end

    describe '.choose' do
      before do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        en = lang.create! :name => 'en', :plural => 'n==1?0:1'
        fr = lang.create! :name => 'fr', :plural => 'n>1?1:0'
      end

      it 'should choose the first language if list is empty' do
        @provider.choose([]).should == 'en'
      end

      it 'should choose the first language except from the list' do
        @provider.choose(['en']).should == 'fr'
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
