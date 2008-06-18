require 'yaml'
require 'ftools'

module Merb
  module Global
    module Providers
      class Yaml #:nodoc:
        include Merb::Global::Provider
        include Merb::Global::Provider::Importer
        include Merb::Global::Provider::Exporter
        
        def initialize
          # Not synchronized - make GC do it's work (may be not optimal
          # but I don't think that some problem will occure).
          # Shouldn't it be sort of cache with some expiration limit?
          @lang = Hash.new
        end

        def translate_to(singular, plural, opts)
          unless @lang.include? opts[:lang]
            file = File.join Merb::Global::Providers.localedir,
                             opts[:lang] + '.yaml'
            if File.exist? file
              @lang[opts[:lang]] = YAML.load_file file
            else
              @lang[opts[:lang]] = nil
            end
          end

          unless @lang[opts[:lang]].nil?
            lang = @lang[opts[:lang]]
            unless lang[singular].nil?
              unless plural.nil?
                n = Merb::Global::Plural.which_form opts[:n], lang[:plural]
                return lang[singular][n] unless lang[singular][n].nil?
              else
                return lang[singular] unless lang[singular].nil?
              end
            end
          end
          return opts[:n] > 1 ? plural : singular
        end

        def support?(lang)
          unless @lang.include? lang
            file = File.join Merb::Global::Providers.localedir, lang + '.yaml'
            @lang[lang] = YAML.load_file file if File.exist? file
          end
          not @lang[lang].nil?
        end

        def create!
          File.mkdirs Merb::Global::Providers.localedir
        end

        def choose(except)
          dir = Dir[Merb::Global::Providers.localedir + '/*.yaml']
          dir.collect! {|p| File.basename p, '.yaml'}
          dir.reject! {|lang| except.include? lang}
          dir.first
        end

        def import(exporter)
          Dir[Merb::Global::Providers.localedir + '/*.yaml'].each do |file|
            lang_name = File.basename p, '.yaml'
            lang = YAML.file_load file
            exporter.export_language lang_name, lang[:plural]
            lang.each do |msgid, msgstr|
              if msgid.is_a? String
                if msgstr.is_a? Hash
                  msgstr.each do |msgstr_index, msgstr|
                    export_string lang_name, msgid, msgstr_index, msgstr
                  end
                else
                  export_string lang_name, msgid, nil, msgstr
                end
              end
            end
          end
        end

        def export
          @languages = {}
          yield
          File.unlink *Dir[Merb::Global::Providers.localedir + '/*.yaml']
          @languages.each do |lang, language|
            open "#{Merb::Global::Providers.localedir}/#{lang}.yaml" do |out|
              YAML.dump(language, out)
            end
          end
          @languages = nil
        end

        def export_language(language, plural)
          @languages[language] = {:plural => plural}
        end

        def export_string(language, msgid, no, msgstr)
          if no.nil?
            @languages[language][msgid] = msgstr
          else
            @languages[language][msgid] ||= {}
            @languages[language][msgid][no] = msgstr
          end
        end
      end
    end
  end
end
