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
          unless plural.nil?
            context.ngettext singular, plural, opts[:n]
          else
            context.gettext singular
          end
        end

        def support?(lang)
          lang == 'en' ||
            File.exist?(File.join(Merb::Global::Providers.localedir, lang))
        end

        def create!
          File.mkdirs Merb::Global::Providers.localedir
        end

        def choose(except)
          dir = Dir[Merb::Global::Providers.localedir + '/*/']
          dir.collect! {|p| File.basename p}
          dir << 'en'
          dir.reject! {|lang| except.include? lang}
          dir.first
        end

        class GettextContext
          include ::GetText
          bindtextdomain Merb::Global.config([:gettext, :domain], 'merbapp'),
                         Merb::Global::Providers.localedir
          public :set_locale, :ngettext, :gettext
        end
      end
    end
  end
end
