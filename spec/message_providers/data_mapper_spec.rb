require 'spec_helper'

if HAS_DM
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
        en = Merb::Global::Locale.new('en')
        @provider.support?(en).should == true
      end

      it 'should return false otherwise' do
        fr = Merb::Global::Locale.new('fr')
        @provider.support?(fr).should == false
      end
    end

    describe '.localize' do
      before do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        en = lang.create! :name => 'en', :plural => 'n==1?0:1', :nplural => 2
        trans = Merb::Global::MessageProviders::DataMapper::Translation
        trans.create! :language_id => en.id,
                      :msgid => 'Test', :msgid_plural => 'Tests',
                      :msgstr => 'One test', :msgstr_index => 0
        trans.create! :language_id => en.id,
                      :msgid => 'Test', :msgid_plural => 'Tests',
                      :msgstr => 'Many tests', :msgstr_index => 1
        trans.create! :language_id => en.id,
                      :msgid => 'Hello', :msgid_plural => nil,
                      :msgstr => 'Hello world!', :msgstr_index => nil
      end

      it 'should fetch the correct translation from database if avaible' do
        trans = @provider.localize('Test', 'Tests', 1, 'en')
        trans.should == 'One test'
        trans = @provider.localize('Hello', nil, 1, 'en')
        trans.should == 'Hello world!'
      end

      it 'should fallback to default if needed' do
        trans = @provider.localize('Test', 'Tests', 2, 'fr')
        trans.should == 'Tests'
      end
    end

    describe '.choose' do
      before do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        en = lang.create! :name => 'en', :plural => 'n==1?0:1', :nplural => 2
        fr = lang.create! :name => 'fr', :plural => 'n>1?1:0', :nplural => 2
      end

      it 'should choose the first language if list is empty' do
        @provider.choose([]).should == 'en'
      end

      it 'should choose the first language except from the list' do
        @provider.choose(['en']).should == 'fr'
      end
    end

    describe '.import' do
      before do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        en = lang.create! :name => 'en', :plural => 'n==1?0:1', :nplural => 2
        trans = Merb::Global::MessageProviders::DataMapper::Translation
        trans.create! :language_id => en.id,
                      :msgid => 'Test', :msgid_plural => 'Tests',
                      :msgstr => 'One test', :msgstr_index => 0
        trans.create! :language_id => en.id,
                      :msgid => 'Test', :msgid_plural => 'Tests',
                      :msgstr => 'Many tests', :msgstr_index => 1
        trans.create! :language_id => en.id,
                      :msgid => 'Hello', :msgid_plural => nil,
                      :msgstr => 'Hello world!', :msgstr_index => nil
      end
      
      it 'should put data in the hash' do
        @provider.import.should == {
          "en" => {
            :nplural => 2, :plural => 'n==1?0:1',
            'Hello' => {
              :plural => nil,
              nil => 'Hello world!'
            },
            'Test' => {
              :plural => 'Tests',
              0 => 'One test',
              1 => 'Many tests'
            }
          }
        }
      end
    end

    describe '.export' do
      it 'should transform data from hash into the database' do
        lang = Merb::Global::MessageProviders::DataMapper::Language
        trans = Merb::Global::MessageProviders::DataMapper::Translation
        en = mock do |en|
          en.stubs(:id).returns(1)
        end
        lang.expects(:create!).
             with(:name => 'en', :nplural => 2, :plural => 'n==1?0:1').
             returns(en)
        trans.expects(:create!).
              with(:language_id => en.id,
                   :msgid => 'Test', :msgid_plural => 'Tests',
                   :msgstr => 'One test', :msgstr_index => 0).
              returns(mock)
        trans.expects(:create!).
              with(:language_id => en.id,
                   :msgid => 'Test', :msgid_plural => 'Tests',
                   :msgstr => 'Many tests', :msgstr_index => 1).
              returns(mock)
        trans.expects(:create!).
              with(:language_id => en.id,
                   :msgid => 'Hello', :msgid_plural => nil,
                   :msgstr => 'Hello world!', :msgstr_index => nil).
              returns(mock)
        @provider.export("en" => {
                           :nplural => 2, :plural => 'n==1?0:1',
                           'Hello' => {
                             :plural => nil,
                             nil => 'Hello world!'
                           },
                           'Test' => {
                             :plural => 'Tests',
                             0 => 'One test',
                             1 => 'Many tests'
                           }
                         })
      end
    end
  end
end
