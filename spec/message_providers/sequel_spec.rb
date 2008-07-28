require 'spec_helper'

if HAS_SEQUEL

  DB = Sequel.open 'sqlite:///'

  require 'merb_global/message_providers/sequel'
  load    Pathname(__FILE__).dirname.parent.parent.expand_path +
          'sequel_generators/translations_migration/templates/' +
          'translations_migration.erb'

  describe Merb::Global::MessageProviders::Sequel::AddTranslationsMigration do
    before do
      migration =
        Merb::Global::MessageProviders::Sequel::AddTranslationsMigration
      @migration = migration.new DB
    end

    describe '.up' do
      it 'should migrate the database' do
        @migration.up
      end
    end

    describe '.down' do
      it 'should remove the effects' do
        @migration.down
      end
    end
  end

  describe Merb::Global::MessageProviders::Sequel do
    before do
      @provider = Merb::Global::MessageProviders::Sequel.new
      migration =
        Merb::Global::MessageProviders::Sequel::AddTranslationsMigration
      migration.new(DB).up rescue nil
    end

    after do
      migration =
        Merb::Global::MessageProviders::Sequel::AddTranslationsMigration
      migration.new(DB).down rescue nil
    end

    describe '.create!' do
      it 'should check if migration exists and print message if yes' do
        file = mock do |file|
          file.expects(:=~).with(/translations\.rb/).returns(true)
        end
        dir = File.join Merb.root, 'schema', 'migrations', '*.rb'
        dir_mock = mock do |dir_mock|
          dir_mock.expects(:detect).yields(file).returns(true)
        end
        Dir.stubs(:[]).returns([])
        Dir.expects(:[]).with(dir).returns(dir_mock)
        @provider.expects(:puts)
        @provider.stubs(:sh)
        @provider.create!
      end

      it 'should run the script if migration exists' do
        file = mock do |file|
          file.expects(:=~).with(/translations\.rb/).returns(true)
        end
        dir = File.join Merb.root, 'schema', 'migrations', '*.rb'
        dir_mock = mock do |dir_mock|
          dir_mock.expects(:detect).yields(file).returns(false)
        end
        Dir.expects(:[]).with(dir).returns(dir_mock)
        @provider.expects(:sh).with(%{merb-gen translations_migration})
        @provider.create!
      end
    end

    describe '.support?' do
      before do
        lang = Merb::Global::MessageProviders::Sequel::Language
        lang.create :name => 'en', :plural => 'n==1?1:0'
      end

      it 'should return true if language has entry in database' do
        @provider.support?('en').should == true
      end

      it 'should otherwise return false' do
        @provider.support?('fr').should == false
      end
    end

    describe '.localize' do
      before do
        lang = Merb::Global::MessageProviders::Sequel::Language
        trans = Merb::Global::MessageProviders::Sequel::Translation
        en = lang.create :name => 'en', :plural => 'n==1?0:1'
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'One test', :msgstr_index => 0
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'Many tests', :msgstr_index => 1
        trans.create :language_id => en.id,
                     :msgid => 'Hello', :msgid_plural => nil,
                     :msgstr => 'Hello world!', :msgstr_index => nil
      end

      it 'should find it in database and return proper translation' do
        trans = @provider.localize 'Test', 'Tests', :n => 1, :lang => 'en'
        trans.should == 'One test'
        trans = @provider.localize 'Test', 'Tests', :n => 2, :lang => 'en'
        trans.should == 'Many tests'
        trans = @provider.localize 'Hello', nil, :n => 1, :lang => 'en'
        trans.should == 'Hello world!'
      end

      it 'should fallback if not' do
        trans = @provider.localize 'Test', 'Tests', :n => 1,:lang => 'fr'
        trans.should == 'Test'
        trans = @provider.localize 'Car', 'Cars', :n => 2, :lang => 'en'
        trans.should == 'Cars'
      end
    end

    describe '.choose' do
      before do
        lang = Merb::Global::MessageProviders::Sequel::Language
        en = lang.create :name => 'en', :plural => 'n==1?0:1'
        fr = lang.create :name => 'fr', :plural => 'n>1?1:0'
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
        lang = Merb::Global::MessageProviders::Sequel::Language
        trans = Merb::Global::MessageProviders::Sequel::Translation
        en = lang.create :name => 'en', :nplural => 2, :plural => 'n==1?0:1'
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'One test', :msgstr_index => 0
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'Many tests', :msgstr_index => 1
        trans.create :language_id => en.id,
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
        lang = Merb::Global::MessageProviders::Sequel::Language
        trans = Merb::Global::MessageProviders::Sequel::Translation
        en = mock do |en|
          en.stubs(:[]).with(:id).returns(1)
        end
        lang.expects(:create).
             with(:name => 'en', :nplural => 2, :plural => 'n==1?0:1').
             returns(en)
        trans.expects(:create).
              with(:language_id => en[:id],
                   :msgid => 'Test', :msgid_plural => 'Tests',
                   :msgstr => 'One test', :msgstr_index => 0).returns(1)
        trans.expects(:create).
              with(:language_id => en[:id],
                   :msgid => 'Test', :msgid_plural => 'Tests',
                   :msgstr => 'Many tests', :msgstr_index => 1).returns(2)
        trans.expects(:create).
              with(:language_id => en[:id],
                   :msgid => 'Hello', :msgid_plural => nil,
                   :msgstr => 'Hello world!', :msgstr_index => nil).returns(3)
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
