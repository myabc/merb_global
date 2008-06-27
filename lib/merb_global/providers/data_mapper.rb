require 'data_mapper'
require 'dm-aggregates'
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class DataMapper #:nodoc: all
        include Merb::Global::Providers
        include Merb::Global::Providers::Base::Importer
        include Merb::Global::Providers::Base::Exporter

        def translate_to(singular, plural, opts)
          # I hope it's from MemCache
          language = Language.first :name => opts[:lang]
          unless language.nil?
            unless plural.nil?
              n = Plural.which_form opts[:n], language.plural
              translation = Translation.first :language_id => language.id,
                                              :msgid => singular,
                                              :msgstr_index => n
            else
              translation = Translation.first :language_id => language.id,
                                              :msgid => singular,
                                              :msgstr_index => nil
            end
            return translation.msgstr unless translation.nil?
          end
          # Fallback if not in database
          return opts[:n] != 1 ? plural : singular
        end

        def support?(lang)
          not Language.first(:name => lang).nil?
        end

        def create!
          Language.auto_migrate!
          Translation.auto_migrate!
        end

        def choose(except)
          Language.first(:name.not => except).name
        end

        def import
          data = {}
          ::DataMapper::Transaction.new(Language, Translation) do
            Language.all.each do |language|
              data[lang.name] = lang_hash = {
                :plural => lang.plural,
                :nplural => lang.nplural
              }
              language.translations.each do |translation|
                lang_hash[translation.msgid] ||= {
                  :plural => translation.msgid_plural
                }
                lang_hash[translation.msgid][translation.msgstr_index] =
                  translation.msgstr
              end
            end
          end
        end

        def export(data)
          ::DataMapper::Transaction.new(Language, Translation) do
            Translation.all.each {|translation| translation.destroy}
            Language.all.each {|language| language.destroy}
            data.each do |lang_name, lang|
              lang_obj = Language.new(:name => lang_name,
                                      :plural => lang[:plural]
                                      :nplural => lang[:nplural])
              lang_obj.save or raise
              lang.each do |msgid, msgstr|
                Translation.new(:language_id => lang_obj.id,
                                :msgid => msgid,
                                :msgid_plural => nil,
                                :msgstr => msgstr,
                                :msgstr_index => nil).save or raise
              end
            end
          end
        end

        # When table structure becomes stable it *should* be documented
        class Language
          include ::DataMapper::Resource
          storage_names[:default] = 'merb_global_languages'
          property :id, Integer, :serial => true
          property :name, String, :unique_index => true
          property :nplural, Integer
          property :plural, Text, :lazy => false
          # validates_is_unique :name
          has n, :translations,
            :class_name => "Merb::Global::Providers::DataMapper::Translation",
            :child_key => [:language_id]
        end

        class Translation
          include ::DataMapper::Resource
          storage_names[:default] = 'merb_global_translations'
          property :language_id, Integer, :nullable => false, :key => true
          property :msgid, Text, :nullable => false, :key => true
          property :msgid_plural, Text, :lazy => true
          property :msgstr, Text, :nullable => false, :lazy => false
          property :msgstr_index, Integer, :nullable => true, :key => true
          belongs_to :language, :class_name =>  Language.name
        end
      end
    end
  end
end
