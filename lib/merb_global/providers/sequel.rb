require 'sequel'
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class Sequel < Merb::Global::Provider #:nodoc: all
        def translate_to(singular, plural, opts)
          language = Language[:name => opts[:lang]] # I hope it's from MemCache
          unless language.nil?
            unless plural.nil?
              n = Plural.which_form opts[:n], language[:plural]
              translation = Translation[language.pk, singular.hash, n]
            else
              translation = Translation[language.pk, singular.hash, nil]
            end
            return translation[:msgstr] unless translation.nil?
          end
          return opts[:n] > 1 ? plural : singular # Fallback if not in database
        end

        def support?(lang)
          Language.filter(:name => lang).count != 0
        end

        def create!
          migration_exists = Dir[File.join(Merb.root, 'schema',
                                           'migrations', "*.rb")].detect do |f|
            f =~ /translations\.rb/
          end
          if migration_exists
            puts "\nThe Translation Migration File already exists\n\n"
          else
            sh %{merb-gen translations_migration}
          end
        end

        def choose(except)
          Language.filter {:name != except}.first[:name]
        end

        class Language < ::Sequel::Model(:merb_global_languages)
        end

        class Translation < ::Sequel::Model(:merb_global_translations)
          set_primary_key :language_id, :msgid_hash, :msgstr_index
        end
      end
    end
  end
end
