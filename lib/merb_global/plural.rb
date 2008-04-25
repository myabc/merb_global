module Merb
  module Global
    module Plural
      # Returns which form should be returned
      # ==== Parameters
      # n<Fixnum>:: A number of elements
      # plural<String>:: Expression
      # ==== Returns
      # Fixnum:: Which form should be translated
      def self.which_form n, plural
        # Mock version
	n > 0 ? 1 : 0
      end
    end
  end
end
