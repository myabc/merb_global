require 'data_mapper'
require 'dm-aggregates'
require 'merb_global/plural'

module Merb
  module Global
    module Providers
      class DataMapper #:nodoc: all
        include Merb::Global::Provider
        include Merb::Global::Provider::Importer
        include Merb::Global::Provider::Exporter
        
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

        def import(exporter, export_data)
          ::DataMapper::Transaction.new(Language, Translation) do
            Language.all.each do |language|
              exporter.export_language export_data, language.name,
                                       language.nplural,
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

        def export
          ::DataMapper::Transaction.new(Language, Translation) do
            Language.all.each {|language| language.destroy}
            Translation.all.each {|translation| translation.destroy}
            yield nil
          end
        end

        def export_language(export_data, language, nplural, plural)
          lang = Language.new :language => language, :nplural => nplural,
                              :plural => plural
          lang.save
          raise if lang.new_record?
          yield lang.id
        end

        def export_string(language_id, msgid, msgid_plural,
                                       msgstr, msgstr_index)
          trans = Translation.new :language_id => language_id,
                                  :msgid => msgid,
                                  :msgid_plural => msgid_plural,
                                  :msgstr => msgstr,
                                  :msgstr_index => msgstr_index
          trans.save
          raise if lang.new_record?
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
          # Sould it be propery :msgid, :text?
          # This form should be faster. However:
          # - collision may appear (despite being unpropable)
          # - it may be wrong optimalisation
          # As far I'll leave it in this form. If anybody could measure the
          # speed of both methods it will be appreciate.
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
