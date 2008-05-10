module Merb
  module Global
    module Plural
      # Returns which form should be returned
      # ==== Parameters
      # n<Fixnum>:: A number of elements
      # plural<String>:: Expression
      # ==== Returns
      # Fixnum:: Which form should be translated
      def self.which_form(n, plural)
        eval plural
      end
    end
  end
end
