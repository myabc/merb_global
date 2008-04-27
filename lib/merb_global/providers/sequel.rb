require 'sequel'

module Merb
  module Global
    module Providers
      class Sequel #:nodoc:
        def translate_to singular, plural, opts
          language = Language[:name => opts[:lang]] # I hope it's from MemCache
          n = Plural.which_form n, language.plural
          Translation[language.pk, singular.hash, n].msgstr
        end
        class Language < Sequel::Model
        end
        class Translation < Sequel::Model
          set_primery_key [:language_id, :msgid_hash, :msgstr_index]
        end
      end
    end
  end
end
