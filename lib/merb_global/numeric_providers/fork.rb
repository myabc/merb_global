require 'inline'

module Merb
  module Global
    module NumericProviders
      class Fork
        include Merb::Global::DateProviders::Base

        def localize(lang, number)
          pipe_rd, pipe_wr = IO.pipe
          pid = fork do
            pipe_rd.close
            setlocale(lang)
            pipe_wr.write(number)
            pipe_wr.flush
          end
          pipe_wr.close
          Process.wait(pid)
          pipe_rd.read
        end

        inline do |builder|
          builder.include '<locale.h>'
          builder.c <<C
void set_locale(const char *locale)
{
  setlocale(LC_ALL, locale);
}
C
        end
        private :set_locale
      end
    end
  end
end
