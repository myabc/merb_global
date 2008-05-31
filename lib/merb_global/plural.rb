require 'treetop'

module Merb
  module Global
    module Plural
      @parser = Treetop.load('plural').new

      # Returns which form should be returned
      # ==== Parameters
      # n<Fixnum>:: A number of elements
      # plural<String>:: Expression
      # ==== Returns
      # Fixnum:: Which form should be translated
      def self.which_form(n, plural)
        @parser.parse(plural).to_lambda.call(n)
      end
    end
  end
end
