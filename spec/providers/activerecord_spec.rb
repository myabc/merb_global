require 'spec_helper'
require 'sequel'
require 'merb_global/providers/activerecord'

load    Pathname(__FILE__).dirname.parent.parent.expand_path +
        'activerecord_generators/translations_migration/templates/' +
        'translations_migration.erb'

describe Merb::Global::Providers::ActiveRecord::AddTranslationsMigration do
  before do

  end
  describe '.up' do

  end
  describe '.down' do

  end
end

describe Merb::Global::Providers::ActiveRecord do
  describe '.create!' do

  end
  describe '.support?' do
    
  end
  describe '.translate_to' do

  end
end
