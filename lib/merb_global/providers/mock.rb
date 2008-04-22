module Merb
  module Global
    module Providers
      class Mock
        def translate_to string, lang
          string
        end
      end
    end
  end
end
