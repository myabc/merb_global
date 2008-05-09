require 'gettext'

# I'm not sure if it is the correct way of doing it.
# As far it seems to be simpler.
class Thread
  def gettext_context #:nodoc:
    @gettext_context ||= Merb::Global::Providers::Gettext::GettextContext.new
  end
end

module Merb
  module Global
    module Providers
      class Gettext < Merb::Global::Provider #:nodoc: all
        def translate_to singular, plural, opts
          context = Thread.current.gettext_context
          context.locale = Locale::Object.new opts[:lang]
          context.ngettext(singular, plural, opts[:n])
        end
        def supported? lang
          # I know it's a hack - but it should work
          File.directory? File.join(Merb.root, 'app', 'locale', lang)
        end
        class GettextContext
          include GetText
          # Please change it to proper location
          bindtextdomian "merbapp", File.join(Merb.root, 'app', 'locale')
        end
      end
    end
  end
end
