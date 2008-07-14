require 'merb_global/config'
require 'merb_global/plural'
require 'merb_global/date_providers'
require 'merb_global/message_providers'
require 'merb_global/numeric_providers'

module Merb
  module Global
    attr_accessor :lang, :message_provider, :date_provider, :numeric_provider

    def lang #:nodoc:
      @lang ||= 'en'
    end

    def message_provider #:nodoc:
      @message_provider ||= Merb::Global::MessageProviders.provider
    end

    def date_provider #:nodoc:
      @date_provider ||= Merb::Global::DateProviders.provider
    end

    def numeric_provider #:nodoc:
      @numeric_provider ||= Merb::Global::NumericProviders.provider
    end

    # call-seq:
    #   _(singular, opts)          => translated message
    #   _(singlular, plural, opts) => translated message
    #   _(date, format)            => localized date
    #   _(number)                  => localized number
    #
    # Translate a string.
    # ==== Parameters
    # singular<String>:: A string to translate
    # plural<String>:: A plural form of string
    # opts<Hash>:: An options hash (see below)
    # date<~strftime>:: A date to localize
    # format<String>:: A format of string (should be compatibile with strftime)
    # number<Numeric>:: A numeber to localize
    #
    # ==== Options (opts)
    # :lang<String>:: A language to translate on
    # :n<Fixnum>:: A number of objects (for messages)
    #
    # ==== Returns
    # translated<String>:: A translated string
    #
    # ==== Example
    # <tt>render _('%d file deleted', '%d files deleted', :n => del) % del</tt>
    def _(*args)
      opts = {:lang => self.lang, :n => 1}
      opts.merge! args.pop if args.last.is_a? Hash
      if args.first.respond_to? :strftime
        if args.size == 2
          self.date_provider.localize opts[:lang], args[0], args[1]
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
        end
      elsif args.first.is_a? Numeric
        if args.size == 1
          self.numeric_provider.localize opts[:lang], args.first
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1)"
        end
      elsif args.first.is_a? String
        if args.size == 1
          self.message_provider.translate_to args[0], nil, opts
        elsif args.size == 2
          self.message_provider.translate_to args[0], args[1], opts
        else
          raise ArgumentError,
                "wrong number of arguments (#{args.size} for 1-2)"
        end
      else
        raise ArgumentError,
              "wrong type of arguments - see documentation for details"
      end
    end
  end
end
