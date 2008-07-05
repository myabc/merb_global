module Merb
  module Global
    module DateProviders
      class Cli
        include Merb::Global::DateProviders::Base
        
        def localize(date, format)
          # TODO: Implement escaping - potential security issue here!!!
          `date -d '#{date.strftime('%F %X')}' '+#{format}'`
        end
      end
    end
  end
end
