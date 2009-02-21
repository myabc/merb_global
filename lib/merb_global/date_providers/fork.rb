require 'inline'

module Merb
  module Global
    module DateProviders
      class Fork
        include Merb::Global::DateProviders::Base

        def localize(lang, date, format)
          pipe_rd, pipe_wr = IO.pipe
          # setlocale have no guarantee of being thread-safe so for safty
          # we fork the process.
          pid = fork do
            pipe_rd.close
            setlocale(lang.to_s)
            pipe_wr.write(date.strftime(format))
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
