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
      # plural<String>:: A plural form of string (nil if only singular)
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
      def translate_to(singular, plural, opts)
        raise NoMethodError.new('method translate_to has not been implemented')
      end

      # call-seq:
      #     support?(lang) => supported
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
      def support?(lang)
        raise NoMethodError.new('method support? has not been implemented')
      end

      # This method creates basic files and/or directory structures
      # (for example it adds migration) needed for provider to work.
      #
      # It is called from Rakefile.
      def create!
        raise NoMethodError.new('method create! has not been implemented')
      end
      
      # This method choos an supported language except those form the list
      # given. It may fallback to english if none language can be found
      # which agree with those criteria
      def choose(except)
        raise NoMethodError.new('method choose has not been implemented')
      end
    end
  end
end
