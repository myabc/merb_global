require 'yaml'
require 'fileutils'

module Merb
  module Global
    module MessageProviders
      class Yaml #:nodoc:
        include Merb::Global::MessageProviders::Base
        include Merb::Global::MessageProviders::Base::Importer
        include Merb::Global::MessageProviders::Base::Exporter

        def initialize
          # Not synchronized - make GC do it's work (may be not optimal
          # but I don't think that some problem will occure).
          # Shouldn't it be sort of cache with some expiration limit?
          @lang = Hash.new
        end

        def translate_to(singular, plural, opts)
          unless @lang.include? opts[:lang]
            file = File.join Merb::Global::MessageProviders.localedir,
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
            file = File.join Merb::Global::MessageProviders.localedir,
                             lang + '.yaml'
            @lang[lang] = YAML.load_file file if File.exist? file
          end
          not @lang[lang].nil?
        end

        def create!
          FileUtils.mkdir_p Merb::Global::MessageProviders.localedir
        end

        def choose(except)
          dir = Dir[Merb::Global::MessageProviders.localedir + '/*.yaml']
          dir.collect! {|p| File.basename p, '.yaml'}
          dir.reject! {|lang| except.include? lang}
          dir.first
        end

        def import
          data = {}
          Dir[Merb::Global::MessageProviders.localedir +
              '/*.yaml'].each do |file|
            lang_name = File.basename file, '.yaml'
            data[lang_name] = lang = YAML.load_file(file)
            lang.each do |msgid, msgstr|
              if msgstr.is_a? String and msgid.is_a? String
                lang[msgid] = {nil => msgstr}
              end
            end
          end
          data
        end
        
        def export(data)
          File.unlink *Dir[Merb::Global::MessageProviders.localedir +
                           '/*.yaml']
          data.each do |lang_name, lang_orig|
            lang = {}
            lang_orig.each do |msgid, msgstr_hash|
              lang[msgid] = {}
              msgstr_hash.each do |msgstr_index, msgstr|
                if msgstr_index.nil?
                  lang[msgid] = msgstr
                else
                  lang[msgid][msgstr_index] = msgstr
                end
              end
            end
            YAML.dump File.join(Merb::Global::MessageProviders.localedir,
                                lang_name + '.yaml')
          end
        end
      end
    end
  end
end
