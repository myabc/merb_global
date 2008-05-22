require 'gettext'

# I'm not sure if it is the correct way of doing it.
# As far it seems to be simpler.
class Thread #:nodoc:
  def gettext_context
    @gettext_context ||= Merb::Global::Providers::Gettext::GettextContext.new
  end
end

module Merb
  module Global
    module Providers
      class Gettext < Merb::Global::Provider #:nodoc: all
        def translate_to(singular, plural, opts)
          context = Thread.current.gettext_context
          context.set_locale opts[:lang], true
          context.ngettext(singular, plural, opts[:n])
        end
        def support?(lang)
          File.exist? File.join(Merb::Global::Providers.localedir, lang)
        end
        def create!
          File.mkdirs Merb::Global::Providers.localedir
        end
        class GettextContext
          include ::GetText
          # Please change it to proper location
          bindtextdomain "merbapp", Merb::Global::Providers.localedir
          public :set_locale, :ngettext
        end
      end
    end
  end
end
