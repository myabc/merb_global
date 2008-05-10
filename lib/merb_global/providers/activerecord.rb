require 'activerecord'
# As far as I understend we need it to have compostie keys
# However it may be better idea to drop them.
# As far I implement it in this way - then we will see
require 'composite_primary_keys' # As far as I understend we need
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class Activerecord < Merb::Global::Provider #:nodoc: all
        def translate_to singular, plural, opts
          language = Language.find :first,
                                   :conditions => {:name => opts[:lanf]}
          unless language.nil?
            n = Plural.which_form n, language.plural
            translation = Translation.find [language.pk, singular.hash, n]
            return translation.msgstr unless translation.nil?
          end
          return opts[:n] > 1 ? plural : singular # Fallback if not in database
        end
        def supported? lang
          Language.count(:conditions => {:name => lang}) != 0
        end
        def create!
          migration_exists = Dir[File.join(Merb.root,"schema",
                                           "migrations", "*.rb")].detect do |f|
            f =~ /translations\.rb/
          end
          if migration_exists
            puts "\nThe Translation Migration File already exists\n\n"
          else
            sh %{merb-gen translations_migration}
          end
        end
        class Language < ActiveRecord::Base
          set_table_name :merb_global_languages
        end
        class Translation < ActiveRecord::Base
          set_table_name :merb_global_translations
          set_primary_keys :language_id, :msgid_hash, :msgstr_index
        end
      end
    end
  end
end
