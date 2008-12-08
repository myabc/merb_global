require 'java'

module Merb
  module Global
    module NumericProviders
      class Java
        include Merb::Global::DateProviders::Base

        def localize(locale, number)
          java.text.NumberFormat.instance(locale).format(number)
        end
      end
    end
  end
end
