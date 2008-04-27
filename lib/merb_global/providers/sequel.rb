require 'sequel'

module Merb
  module Global
    module Providers
      class Sequel #:nodoc:
        def translate_to singular, plural, opts
          language = Language[:name => opts[:lang]] # I hope it's from MemCache
          unless language.nil?
            n = Plural.which_form opts[:n], language.plural
            translation = Translation[language.pk, singular.hash, n]
            return translation.msgstr unless translation.nil?
          end
          return opts[:n] > 1 ? plural : singular # Fallback if not in database
        end
        class Language < Sequel::Model(:merb_global_lanuages)
        end
        class Translation < Sequel::Model(:merb_global_translations)
          set_primery_key [:language_id, :msgid_hash, :msgstr_index]
        end
      end
    end
  end
end