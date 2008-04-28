require 'data_mapper'

module Merb
  module Global
    module Providers
      class Yaml #:nodoc:
        def initialize
          # Not synchronized - make GC do it's work (may be not optimal 
          # but I don't think that some problem will occure).
          # Shouldn't it be sort of cache with some expiration limit?
          @lang = Hash.new
        end
        def translate_to singular, plural, opts
          unless @lang.include? opts[:lang]
            file = File.join Merb.root, 'lang', opts[:lang] + '.yaml'
            @lang[opts[:lang]] = YAML.load_file file if file.exist? file
          end
          unless opts[:lang].nil?
            lang = @lang[opts[:lang]]
            n = Plural.which_form opts[:n], lang[:plural]
            unless lang[singular].nil?
              return lang[singular][n] unless lang[singular][n].nil?
            end
          end
          return opts[:n] > 1 ? plural : singular
        end
      end
    end
  end
end
