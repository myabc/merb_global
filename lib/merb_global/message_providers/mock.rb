module Merb
  module Global
    module MessageProviders
      class Mock #:nodoc:
        include Merb::Global::MessageProviders::Base

        def translate_to(singular, plural, opts)
          opts[:n] > 1 ? plural : singular
        end

        def support?(lang)
          true
        end

        def create!
          nil # It's mock after all ;)
        end

        def choose
          'en'
        end
      end
    end
  end
end