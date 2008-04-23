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
    # opts<Hash>:: An options hash (see below)
    #
    # ==== Options (opts)
    # :lang<String>:: A language to translate on
    # 
    # ==== Returns
    # String:: A translated string
    #
    # ==== Example
    # <tt>render _("Error %d has occured") % error.errno</tt>
    def _ cstring *args
      defaults = {:lang => self.lang}
      defaults.merge! args.pop if args.last.is_a? Hash
      args.push defaults
      self.provider.translate_to cstring, *args
    end
  end
end
