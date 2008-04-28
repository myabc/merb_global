require 'merb_global/base'

module Merb
  class Controller #:nodoc:
    include Merb::Global
    before do
      # TODO: Language negotation
    end
  end
end
