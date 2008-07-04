require 'merb_global/config'
require 'merb_global/plural'
require 'merb_global/message_providers'

module Merb
  module Global
    attr_accessor :lang, :provider

    def lang #:nodoc:
      @lang ||= 'en'
    end

    def message_provider #:nodoc:
      @provider ||= Merb::Global::MessageProviders.provider
    end

    # call-seq:
    #   _(singular, opts)          => translated
    #   _(singlular, plural, opts) => translated
    #
    # Translate a string.
    # ==== Parameters
    # singular<String>:: A string to translate
    # plural<String>:: A plural form of string
    # opts<Hash>:: An options hash (see below)
    #
    # ==== Options (opts)
    # :lang<String>:: A language to translate on
    # :n<Fixnum>:: A number of objects
    #
    # ==== Returns
    # translated<String>:: A translated string
    #
    # ==== Example
    # <tt>render _('%d file deleted', '%d files deleted', :n => del) % del</tt>
    def _(*args)
      opts = {:lang => self.lang, :n => 1}
      opts.merge! args.pop if args.last.is_a? Hash
      if args.size == 1
        self.provider.translate_to args[0], nil, opts
      elsif args.size == 2
        self.provider.translate_to args[0], args[1], opts
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1-2)"
      end
    end
  end
end
