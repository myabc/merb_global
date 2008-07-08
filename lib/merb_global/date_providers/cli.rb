module Merb
  module Global
    module DateProviders
      class Cli
        include Merb::Global::DateProviders::Base
        
        def localize(lang, date, format)
          # TODO: Implement escaping - potential security issue here!!!
          date = date.strftime('%F %X')
          date = `LANG=#{lang} LC_ALL=#{lang}  date -d '#{date}' '+#{format}'`
          date[0...date.length - 1] # The newline removed
        end
      end
    end
  end
end
