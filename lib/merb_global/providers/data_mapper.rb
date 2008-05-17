require 'data_mapper'
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class DataMapper < Merb::Global::Provider #:nodoc: all
        def translate_to(singular, plural, opts)
          # I hope it's from MemCache
          language = Language.first :name => opts[:lang]
          unless language.nil?
            n = Plural.which_form opts[:n], language.plural
            translation = Translation.first :language_id => language.id,
                                            :msgid_hash => singular.hash,
                                            :msgstr_index => n
            return translation.msgstr unless translation.nil?
          end
          # Fallback if not in database
          return opts[:n] != 1 ? plural : singular
        end
        def support?(lang)
          Language.count(:name => lang) != 0
        end
        def create!
          Language.auto_migrate!
          Translation.auto_migrate!
        end
        # When table structure becomes stable it *should* be documented
        class Language < ::DataMapper::Base
          set_table_name 'merb_global_languages'
          property :name, :string, :index => true # It should be unique
          property :plural, :text, :lazy => false
          validates_uniqueness_of :name
        end
        class Translation < ::DataMapper::Base
          set_table_name 'merb_global_translations'
          property :language_id, :integer, :nullable => false, :key => true
          # Sould it be propery :msgid, :text?
          # This form should be faster. However:
          # - collision may appear (despite being unpropable)
          # - it may be wrong optimalisation
          # As far I'll leave it in this form. If anybody could measure the
          # speed of both methods it will be appreciate.
          property :msgid_hash, :integer, :nullable => false, :key => true
          property :msgstr, :text, :nullable => false, :lazy => false
          property :msgstr_index, :integer, :nullable => false, :key => true
          #belongs_to :language
        end
      end
    end
  end
end
