require 'dm-core'
require 'dm-aggregates'
require 'merb_global/plural'

module Merb
  module Global
    module MessageProviders
      class DataMapper #:nodoc: all
        include Merb::Global::MessageProviders
        include Merb::Global::MessageProviders::Base::Importer
        include Merb::Global::MessageProviders::Base::Exporter

        def localize(singular, plural, n, locale)
          # I hope it's from MemCache
          language = Language.first :name => locale.to_s
          unless language.nil?
            unless plural.nil?
              pn = Plural.which_form n, language.plural
              translation = Translation.first :language_id => language.id,
                                              :msgid => singular,
                                              :msgstr_index => pn
            else
              translation = Translation.first :language_id => language.id,
                                              :msgid => singular,
                                              :msgstr_index => nil
            end
            return translation.msgstr unless translation.nil?
          end
          # Fallback if not in database
          return n != 1 ? plural : singular
        end

        def create!
          Language.auto_migrate!
          Translation.auto_migrate!
        end

        def import
          data = {}
          ::DataMapper::Transaction.new(Language, Translation) do
            Language.all.each do |language|
              data[language.name] = lang_hash = {
                :plural => language.plural,
                :nplural => language.nplural
              }
              language.translations(:fields => Translation.properties.to_a).
                       each do |translation|
                lang_hash[translation.msgid] ||= {
                  :plural => translation.msgid_plural
                }
                lang_hash[translation.msgid][translation.msgstr_index] =
                  translation.msgstr
              end
            end
          end
          data
        end

        def export(data)
          ::DataMapper::Transaction.new(Language, Translation) do
            Translation.all.each {|translation| translation.destroy}
            Language.all.each {|language| language.destroy}
            data.each do |lang_name, lang|
              lang_obj = Language.create!(:name => lang_name,
                                          :plural => lang[:plural],
                                          :nplural => lang[:nplural])
              lang.each do |msgid, msgstr_hash|
                if msgstr_hash.is_a? Hash
                  plural = msgstr_hash[:plural]
                  msgstr_hash.each do |msgstr_index, msgstr|
                    if msgstr_index.nil? or msgstr_index.is_a? Fixnum
                      Translation.create!(:language_id => lang_obj.id,
                                          :msgid => msgid,
                                          :msgid_plural => plural,
                                          :msgstr => msgstr,
                                          :msgstr_index => msgstr_index) or
                                                                          raise
                    end
                  end
                end
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
            :class_name => "Merb::Global::MessageProviders::DataMapper::Translation",
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
