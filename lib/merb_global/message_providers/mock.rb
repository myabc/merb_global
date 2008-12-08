module Merb
  module Global
    module MessageProviders
      class Mock #:nodoc:
        include Merb::Global::MessageProviders::Base

        def localize(singular, plural, n, locale)
          n > 1 ? plural : singular
        end

        def create!
          nil # It's mock after all ;)
        end
      end
    end
  end
end
