require 'merb_global/providers.rb'

module Merb
  module Global
    attr_accessor :lang, :provider
    def lang #:nodoc:
      @lang ||= (ENV['LC_ALL'] || 'C').split('.')[0]
    end
    def provider #:nodoc:
      # @provider ||= Merb::Global::Providers::Gettext
      @provider ||= Merb::Global::Providers::Mock.new
    end
    # Translate a string.
    # ==== Parameters
    # cstring<String>:: A string to translate.
    # lang<String>:: A language to which the cstring should be translated.
    # ==== Returns
    # String:: A translated string
    # ==== Example
    # <tt>render _("Error %d has occured") % error.errno</tt>
    def _ cstring, lang = self.lang
      self.provider.translate_to cstring, lang
    end
  end
end
