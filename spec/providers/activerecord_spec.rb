require 'spec_helper'
require 'activerecord'

ActiveRecord::Base.establish_connection :adapter => "sqlite3",
                                        :database => ":memory:"
ActiveRecord::Migration.verbose = false

require 'merb_global/providers/activerecord'

load    Pathname(__FILE__).dirname.parent.parent.expand_path +
        'activerecord_generators/translations_migration/templates/' +
        'translations_migration.erb'

describe Merb::Global::Providers::ActiveRecord::AddTranslationsMigration do
  before do
    @migration =
        Merb::Global::Providers::ActiveRecord::AddTranslationsMigration
  end
  describe '.up' do
    after do
      @migration.down
    end
    it 'should run the migration' do
     @migration.up
    end
  end
  describe '.down' do
    before do
      @migration.up
    end
    it 'should revert the migration' do
      @migration.down
    end
  end
end

describe Merb::Global::Providers::ActiveRecord do
  before do
    @provider = Merb::Global::Providers::ActiveRecord.new
    @migration =
        Merb::Global::Providers::ActiveRecord::AddTranslationsMigration
    @migration.up
  end
  after do
    @migration.down
  end
  describe '.create!' do
    it 'should check if migration exists and print message if yes' do
      file = mock do |file|
        file.expects(:=~).with(/translations\.rb/).returns(true)
      end
      dir = File.join Merb.root, "schema", "migrations", "*.rb"
      dir_mock = mock do |dir_mock|
        dir_mock.expects(:detect).yields(file).returns(true)
      end
      Merb::Global::Providers::ActiveRecord::Dir = mock do |dir_class|
        dir_class.expects(:[]).with(dir).returns(dir_mock)
      end
      @provider.expects(:puts)
      @provider.create!
    end
    it 'should run the script if migration exists' do
      file = mock do |file|
        file.expects(:=~).with(/translations\.rb/).returns(true)
      end
      dir = File.join Merb.root, "schema", "migrations", "*.rb"
      dir_mock = mock do |dir_mock|
        dir_mock.expects(:detect).yields(file).returns(false)
      end
      Merb::Global::Providers::ActiveRecord::Dir = mock do |dir_class|
        dir_class.stubs(:[]).with(dir).returns(dir_mock)
      end
      @provider.expects(:sh).with(%{merb-gen translations_migration})
      @provider.create!
    end
  end
  describe '.support?' do
    before do
      lang = Merb::Global::Providers::ActiveRecord::Language
      lang.create! :name => 'en', :plural => 'n==1?0:1'
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
      lang = Merb::Global::Providers::ActiveRecord::Language
      trans = Merb::Global::Providers::ActiveRecord::Translation
      en = lang.create! :name => 'en', :plural => 'n==1?0:1'
      trans.create! :language_id => en.id, :msgid_hash => 'Test'.hash,
                   :msgstr => 'One test', :msgstr_index => 0
      trans.create! :language_id => en.id, :msgid_hash => 'Test'.hash,
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
end
