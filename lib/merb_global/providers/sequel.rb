require 'sequel'
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class Sequel #:nodoc: all
        include Merb::Global::Provider
        include Merb::Global::Provider::Importer
        include Merb::Global::Provider::Exporter

        def translate_to(singular, plural, opts)
          language = Language[:name => opts[:lang]] # I hope it's from MemCache
          unless language.nil?
            unless plural.nil?
              n = Plural.which_form opts[:n], language[:plural]
              translation = Translation[language.pk, singular, n]
            else
              translation = Translation[language.pk, singular, nil]
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

        def import(exporter)
          DB.transaction do
            Language.each do |language|
              exporter.export_language language.name do |lang|
                language.translations.each do |translation|
                  exporter.export_string lang, translation.msgid,
                                         translation.msgstr_index,
                                         translation.msgstr
                end
              end
            end
          end
        end

        def export
          DB.transaction do
            Language.delete_all
            Translation.delete_all
            yield
          end
        end

        def export_language(language, plural)
          lang = Language.create :name => language, :plural => plural
          raise unless lang
          yield lang
        end

        def export_string(language_id, msgid, msgstr, msgstr_index)
          Translation.create(:language_id => language_id,
                             :msgid => msgid,
                             :msgstr => msgstr,
                             :msgstr_index => msgstr_index) or raise
        end

        class Language < ::Sequel::Model(:merb_global_languages)
          has_many :translations,
                   :class => "Merb::Global::Providers::Sequel::Translation",
                   :key => :language_id
        end

        class Translation < ::Sequel::Model(:merb_global_translations)
          set_primary_key :language_id, :msgid, :msgstr_index
        end
      end
    end
  end
end
