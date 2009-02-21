require 'merb_global/config'
require 'merb_global/plural'
require 'merb_global/locale'
require 'merb_global/date_providers'
require 'merb_global/message_providers'
require 'merb_global/numeric_providers'

class String
  # call-seq:
  #     localize => localized string
  #
  # Translate the string withing the current locales by default. 
  # ==== Parameters
  # opts<Hash>:: Options of translations
  #
  # ==== Options (opts)
  # locale<Locale>:: The translation in other locale
  # n<Fixnum>:: A number of objects. Please note that it should be used with
  #             plural
  # plural<String>:: Plural form
  #
  def localize(opts = {})
    _opts = {:locale => Merb::Global::Locale.current, :n => 1, :plural => nil}
    _opts.merge!(opts)
    Merb::Global::MessageProviders.provider.localize self, _opts[:plural],
                                                     _opts[:n], _opts[:locale]
  end
end

class Numeric
  # call-seq:
  #     localize => localized number
  #
  # Format the string using the current locale
  # ==== Parameters
  # opts<Hash>:: Options of translations
  #
  # ==== Options (opts)
  # locale<Locale>:: The translation in other locale
  def localize(args = {})
    opts = {:locale => Merb::Global::Locale.current}
    opts.merge!(args)
    Merb::Global::NumericProviders.provider.localize opts[:locale], self
  end
end

class Date
  # call-seq:
  #     localize(format) => localized date
  #
  # Format the string using the current locale
  # ==== Parameters
  # format<String>:: The format - in similar format to Date.to_s
  # opts<Hash>:: Options of translations
  #
  # ==== Options (opts)
  # locale<Locale>:: The translation in other locale
  def localize(format, args = {})
    opts = {:locale => Merb::Global::Locale.current}
    opts.merge!(args)
    Merb::Global::DateProviders.provider.localize opts[:locale], self, format
  end
end

class DateTime
  # call-seq:
  #     localize(format) => localized date
  #
  # Format the string using the current locale
  # ==== Parameters
  # format<String>:: The format - in similar format to DateTime.to_s
  # opts<Hash>:: Options of translations
  #
  # ==== Options (opts)
  # locale<Locale>:: The translation in other locale
  def localize(format, args = {})
    opts = {:locale => Merb::Global::Locale.current}
    opts.merge!(args)
    Merb::Global::DateProviders.provider.localize opts[:locale], self, format
  end
end

class Time
  # call-seq:
  #     localize(format) => localized date
  #
  # Format the string using the current locale
  # ==== Parameters
  # format<String>:: The format - in similar format to Time.to_s
  # opts<Hash>:: Options of translations
  #
  # ==== Options (opts)
  # locale<Locale>:: The translation in other locale
  def localize(format, args = {})
    opts = {:locale => Merb::Global::Locale.current}
    opts.merge!(args)
    Merb::Global::DateProviders.provider.localize opts[:locale], self, format
  end
end

module Merb
  module Global
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
    # :locale<Locale>:: A language to translate on
    # :n<Fixnum>:: A number of objects (for messages)
    #
    # ==== Returns
    # translated<String>:: A translated string
    #
    # ==== Example
    # <tt>render _('%d file deleted', '%d files deleted', :n => del) % del</tt>
    def _(*args)
      opts = {:locale => Merb::Global::Locale.current, :n => 1}
      opts.merge! args.pop if args.last.is_a? Hash
      if args.first.respond_to? :strftime
        if args.size == 2
          Merb::Global::DateProviders.provider.localize opts[:locale], args[0], args[1]
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
        end
      elsif args.first.is_a? Numeric
        if args.size == 1
          Merb::Global::NumericProviders.provider.localize opts[:locale], args.first
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1)"
        end
      elsif args.first.is_a? String
        if args.size == 1
          Merb::Global::MessageProviders.provider.localize args[0], nil, opts[:n], opts[:locale]
        elsif args.size == 2
          Merb::Global::MessageProviders.provider.localize args[0], args[1], opts[:n], opts[:locale]
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
