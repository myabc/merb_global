module Merb
  module Global
    # Merb-global is able to store the translations in different types of
    # storage. An interface betwean merb-global and those storages are
    # providers.
    class Provider
      # call-seq:
      #     translate_to(singular, plural, opts) => translated
      #
      # Translate string using specific provider.
      # It should be overloaded by the implementator.
      #
      # Do not use this method directly - use Merb::Global._ instead
      #
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
      # ==== Raises
      # NoMethodError:: Raised by default implementation. Should not be thrown.
      def translate_to singular, plural, opts
        raise NoMethodError.new 'method translate_to has not been implemented'
      end
      # call-seq: 
      #     supported?(lang) => supported
      #
      # Checks if the language is supported (i.e. if the translation exists).
      #
      # In normal merb app the language is checked automatically in controller
      # so probably you don't have to use this method
      # 
      # ==== Parameters
      # lang<String>:: A code of language 
      #
      # ==== Returns
      # supported<Boolean>:: Is a program translated to this language
      # 
      # ==== Raises
      # NoMethodError:: Raised by default implementation. Should not be thrown.
      def supported? lang
        raise NoMethodError.new'method supported? has not been implemented'
      end
    end
  end
end
