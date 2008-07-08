module Merb
  module Global
    module DateProviders
      class Cli
        include Merb::Global::DateProviders::Base
        
        def localize(lang, date, format)
          # TODO: Implement escaping - potential security issue here!!!
          date = date.strftime('%F %X')
          `LANG=#{lang} LC_ALL=#{lang}  date -d '#{date}' '+#{format}'`
        end
      end
    end
  end
end
