require 'yaml'

module Merb
  module Global
    module Providers
      class Yaml < Merb::Global::Provider #:nodoc:
        def initialize
          # Not synchronized - make GC do it's work (may be not optimal
          # but I don't think that some problem will occure).
          # Shouldn't it be sort of cache with some expiration limit?
          @lang = Hash.new
        end
        def translate_to(singular, plural, opts)
          unless @lang.include? opts[:lang]
            file = File.join Merb.root, 'app', 'locale', opts[:lang] + '.yaml'
            if File.exist? file
              @lang[opts[:lang]] = YAML.load_file file
            else
              @lang[opts[:lang]] = nil
            end
          end
          unless @lang[opts[:lang]].nil?
            lang = @lang[opts[:lang]]
            n = Merb::Global::Plural.which_form opts[:n], lang[:plural]
            unless lang[singular].nil?
              return lang[singular][n] unless lang[singular][n].nil?
            end
          end
          return opts[:n] > 1 ? plural : singular
        end
        def support?(lang)
          unless @lang.include? lang
            file = File.join Merb.root, 'app', 'locale', lang + '.yaml'
            @lang[lang] = YAML.load_file file if File.exist? file
          end
          not @lang[lang].nil?
        end
        def create!
          require 'ftools'
          File.mkdirs File.join(Merb.root, 'app', 'locale')
        end
      end
    end
  end
end
