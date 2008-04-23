module Merb
  module Global
    module Providers
      class Mock #:nodoc:
        def translate_to cstring, *args
          cstring
        end
      end
    end
  end
end
