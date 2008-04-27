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
          if @lang[opts[:lang]].nil?
            file = File.join Merb.root, 'langs', opts[:lang]
            @lang[opts[:lang]] = YAML.load_file file
          end
          lang = @lang[opts[:lang]]
          n = Plural.which_form opts[:n], lang[:plural]
          lang[singular][n]
        end
      end
    end
  end
end
