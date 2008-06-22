require 'spec_helper'

if HAS_SEQUEL

  DB = Sequel.open 'sqlite:///'

  require 'merb_global/providers/sequel'
  load    Pathname(__FILE__).dirname.parent.parent.expand_path +
          'sequel_generators/translations_migration/templates/' +
          'translations_migration.erb'

  describe Merb::Global::Providers::Sequel::AddTranslationsMigration do
    before do
      migration = Merb::Global::Providers::Sequel::AddTranslationsMigration
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

  describe Merb::Global::Providers::Sequel do
    before do
      @provider = Merb::Global::Providers::Sequel.new
      migration = Merb::Global::Providers::Sequel::AddTranslationsMigration
      migration.new(DB).up rescue nil
    end

    after do
      migration = Merb::Global::Providers::Sequel::AddTranslationsMigration
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
        Dir.expects(:[]).with(dir).returns(dir_mock)
        @provider.expects(:puts)
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
        lang = Merb::Global::Providers::Sequel::Language
        lang.create :name => 'en', :plural => 'n==1?1:0'
      end

      it 'should return true if language has entry in database' do
        @provider.support?('en').should == true
      end

      it 'should otherwise return false' do
        @provider.support?('fr').should == false
      end
    end

    describe '.translate_to' do
      before do
        lang = Merb::Global::Providers::Sequel::Language
        trans = Merb::Global::Providers::Sequel::Translation
        en = lang.create :name => 'en', :plural => 'n==1?0:1'
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'One test', :msgstr_index => 0
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'Many tests', :msgstr_index => 1
      end

      it 'should find it in database and return proper translation' do
        trans = @provider.translate_to 'Test', 'Tests', :n => 1, :lang => 'en'
        trans.should == 'One test'
        trans = @provider.translate_to 'Test', 'Tests', :n => 2, :lang => 'en'
        trans.should == 'Many tests'
      end

      it 'should fallback if not' do
        trans = @provider.translate_to 'Test', 'Tests', :n => 1,:lang => 'fr'
        trans.should == 'Test'
        trans = @provider.translate_to 'Car', 'Cars', :n => 2, :lang => 'en'
        trans.should == 'Cars'
      end
    end

    describe '.choose' do
      before do
        lang = Merb::Global::Providers::Sequel::Language
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
      it 'should iterate over the translations' do
        lang = Merb::Global::Providers::Sequel::Language
        trans = Merb::Global::Providers::Sequel::Translation
        en = lang.create :name => 'en', :nplural => 2, :plural => 'n==1?0:1'
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'One test', :msgstr_index => 0
        trans.create :language_id => en.id,
                     :msgid => 'Test', :msgid_plural => 'Tests',
                     :msgstr => 'Many tests', :msgstr_index => 1
        export_data = mock
        en_data = mock
        exporter = mock do |exporter|
          exporter.expects(:export_language).with(export_data, 'en', 2,
                                                  'n==1?0:1').
                                             yields(en_data)
          exporter.expects(:export_string).with(en_data, 'Test', 'Tests',
                                                         0, 'One test')
          exporter.expects(:export_string).with(en_data, 'Test', 'Tests',
                                                         1, 'Many tests')
        end
        @provider.import(exporter, export_data)
      end
    end
    
    describe '.export' do
      it 'should delete all data'
    end
    
    describe '.export_language' do
      it 'should create a new language and yield its id'
    end
    
    describe '.export_string' do
      it 'should create a new translation row'
    end
  end
end
