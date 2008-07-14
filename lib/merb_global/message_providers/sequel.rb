require 'sequel'
require 'merb_global/plural'

module Merb
  module Global
    module MessageProviders
      class Sequel #:nodoc: all
        include Merb::Global::MessageProviders::Base
        include Merb::Global::MessageProviders::Base::Importer
        include Merb::Global::MessageProviders::Base::Exporter

        def localize(singular, plural, opts)
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
          Language.filter(~{:name => except}).first[:name]
        end

        def import
          data = {}
          DB.transaction do
            Language.each do |language|
              exporter.export_language export_data, language[:name],
                                                    language[:nplural],
                                                    language[:plural] do |lang|
                language.translations.each do |translation|
                  exporter.export_string lang,
                                         translation[:msgid],
                                         translation[:msgid_plural],
                                         translation[:msgstr_index],
                                         translation[:msgstr]
                end
              end
            end
          end
        end

        def export
          DB.transaction do
            Language.delete_all
            Translation.delete_all
            data.each do |lang_name, lang|
              lang_obj = Language.create(:name => lang_name,
                                         :plural => lang[:plural],
                                         :nplural => lang[:nplural]) or raise
              lang.each do |msgid, msgstr|
                Translation.create(:language_id => lang_obj.id,
                                  :msgid => msgid,
                                  :msgid_plural => nil,
                                  :msgstr => msgstr,
                                  :msgstr_index => nil) or raise
              end
            end
          end
        end

        class Language < ::Sequel::Model(:merb_global_languages)
          has_many :translations,
                   :class => "Merb::Global::MessageProviders::Sequel::Translation",
                   :key => :language_id
        end

        class Translation < ::Sequel::Model(:merb_global_translations)
          set_primary_key :language_id, :msgid, :msgstr_index
        end
      end
    end
  end
end
