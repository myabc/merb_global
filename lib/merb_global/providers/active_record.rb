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
        include Merb::Global::Providers::Base
        include Merb::Global::Providers::Base::Importer
        include Merb::Global::Providers::Base::Exporter

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

        def import
          data = {}
          Language.transaction do
            Translation.transaction do
              Language.find(:all).each do |lang|
                data[lang.name] = lang_hash = {
                  :plural => lang.plural,
                  :nplural => lang.nplural
                }
                lang.translations.each do |translation|
                  lang_hash[translation.msgid] ||= {
                    :plural => translation.msgid_plural
                  }
                  lang_hash[translation.msgid][translation.msgstr_index] =
                    translation.msgstr
                end
              end
            end
          end
          data
        end

        def export(data)
          Language.transaction do
            Translation.transaction do
              Translation.delete_all
              Language.delete_all
              data.each do |lang_name, lang|
                lang_id = Language.create!(:name => lang_name,
                                           :plural => lang[:plural]
                                           :nplural => lang[:nplural]).id
                lang.each do |msgid, msgstr|
                  Translation.create! :language_id => lang_id,
                                      :msgid => msgid,
                                      :msgid_plural => nil,
                                      :msgstr => msgstr,
                                      :msgstr_index => nil
                end
              end
            end
          end
        end

        class Language < ::ActiveRecord::Base
          set_table_name :merb_global_languages
          has_many :translations,
            :class_name =>
              "::Merb::Global::Providers::ActiveRecord::Translation"
        end

        class Translation < ::ActiveRecord::Base
          set_table_name :merb_global_translations
          set_primary_keys :language_id, :msgid, :msgstr_index
        end
      end
    end
  end
end
