module Merb
  module Global
    module Providers
      class Mock #:nodoc:
        def translate_to string, lang
          string
        end
      end
    end
  end
end
