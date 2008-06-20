require 'activerecord'
# As far as I understend we need it to have compostie keys
# However it may be better idea to drop them.
# As far I implement it in this way - then we will see
require 'composite_primary_keys' # As far as I understend we need
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class ActiveRecord #:nodoc: all
        include Merb::Global::Provider
        include Merb::Global::Provider::Importer
        include Merb::Global::Provider::Exporter
        
        def translate_to(singular, plural, opts)
          language = Language.find :first,
                                   :conditions => {:name => opts[:lang]}
          unless language.nil?
            unless plural.nil?
              n = Plural.which_form opts[:n], language.plural
              translation = Translation.find [language.id, singular, n]
            else
              translation = Translation.find [language.id, singular, nil]
            end  
            return translation.msgstr
          end rescue nil
          return opts[:n] > 1 ? plural : singular # Fallback if not in database
        end

        def support?(lang)
          Language.count(:conditions => {:name => lang}) != 0
        end

        def create!
          migration_exists = Dir[File.join(Merb.root, 'schema',
                                           'migrations', '*.rb')].detect do |f|
            f =~ /translations\.rb/
          end
          if migration_exists
            puts "\nThe Translation Migration File already exists\n\n"
          else
            sh %{merb-gen translations_migration}
          end
        end

        def choose(except)
          if except.empty?
            Language.find(:first).name
          else
            condition = 'name NOT IN (' + '?, ' * (except.length - 1) + '?)'
            Language.find(:first, :conditions => [condition, *except]).name
          end
          # On #rubyonrails the following method was given. However I do not
          # trust it. Please change if the validity is confirmed
          # Language.find(:first, :conditions => ['name NOT IN ?',
          #                                       "(#{except.join(',')})"])
        end

        def import(exporter, export_data)
          Language.transaction do
            Translation.transaction do
              Language.find(:all).each do |language|
                exporter.export_language export_data, language.name,
                                         language.plural do |lang|
                  language.translations.each do |translation|
                    exporter.export_string lang, translation.msgid,
                                                 translation.msgid_plural,
                                                 translation.msgstr_index,
                                                 translation.msgstr
                  end
                end
              end
            end
          end
        end

        def export
          Language.transaction do
            Translation.transaction do
              Language.delete_all
              Translation.delete_all
              yield nil
            end
          end
        end

        def export_language(export_data, language, plural)
          yield Language.create!(:language => language, :plural => plural).id
        end

        def export_string(language_id, msgid, msgid_plural,
                                       msgstr, msgstr_index)
          Translation.create! :language_id => language_id,
                              :msgid => msgid,
                              :msgid_plural => msgid_plural,
                              :msgstr => msgstr,
                              :msgstr_index => msgstr_index
        end

        class Language < ::ActiveRecord::Base
          set_table_name :merb_global_languages
          has_many :translations,
            :class_name =>
              "Merb::Global::Providers::ActiveRecord::Translations"
        end

        class Translation < ::ActiveRecord::Base
          set_table_name :merb_global_translations
          set_primary_keys :language_id, :msgid, :msgstr_index
        end
      end
    end
  end
end
