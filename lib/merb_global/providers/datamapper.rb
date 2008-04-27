require 'data_mapper'

module Merb
  module Global
    module Providers
      class Datamapper #:nodoc:
        def translate_to singular, plural, opts
          language = Language[:name => opts[:lang]] # I hope it's from MemCache
          n = Plural.which_form opts[:n], language.plural
          Translation[language.pk, singular.hash, n].msgstr
        end
        # When table structure becomes stable it *should* be documented
        class Language < DataMapper::Base
          property :name, :string, :index => true # It should be unique
          property :plural, :text, :lazy => false
          validates_uniqueness_of :name
        end
        class Translation < DataMapper::Base
          property :language_id, :integer, :nullable => false, :key => true
          # Sould it be propery :msgid, :text?
          # This form should be faster. However:
          # - collision may appear (despite being unpropable)
          # - it may be wrong optimalisation
          # As far I'll leave it in this form. If anybody could measure the
          # speed of both methods it will be appreciate.
          property :msgid_hash, :integer, :nullable => false, :key => true
          property :msgstr, :text, :lazy => false
          property :msgstr_index, :integer, :nullable => false, :key => true
          belongs_to :language
        end
      end
    end
  end
end
