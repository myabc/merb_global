module Merb
  module Global
    module MessageProviders
      @@providers = {}
      @@providers_classes = {}
      ##
      # Creates a provider and/or returns already created one
      #
      # ==== Parames
      # provider<~to_s,~to_sym>:: A name of provider
      #
      # ==== Returns
      # provider<Provider>:: A new provider
      def self.[](provider)
        unless @@providers.include? provider.to_sym
          if @@providers_classes[provider.to_sym]
            @@providers[provider.to_sym] =
              @@providers_classes[provider.to_sym].new
          else
            require 'merb_global/providers/' + provider
            klass = "Merb::Global::MessageProviders::#{provider.camel_case}"
            @@providers[provider.to_sym] = eval "#{klass}.new"
          end
        end
        @@providers[provider.to_sym]
      end

      # call-seq:
      #     localedir => localdir
      #
      # Returns the directory where locales are stored for file-backended
      # providers (such as gettext or yaml)
      #
      # ==== Returns
      # localedir<String>>:: Directory where the locales are stored
      def self.localedir
        localedir =
          if Merb::Global.config :flat
            'locale'
          else
            Merb::Global.config :localedir, File.join('app', 'locale')
          end
        File.join Merb.root, localedir
      end

      # call-seq:
      #     provider => provider
      #
      # Returns the provider of required type
      #
      # ==== Returns
      # provider<Provider>:: Returns provider
      def self.provider
        @@provider ||= self[Merb::Global.config(:provider, 'gettext')]
      end

      # Registers the class under the given name
      # 
      # ==== Parameters
      # name<~to_sym>:: Name under which it is registered
      # klass<Class>:: Class of the provider
      def self.register(name, klass)
        @@provider_classes[name.to_sym] = klass
      end

      # Perform the registration
      #
      # ==== Parameters
      # name<~to_sym>:: Name under which it is registred
      # opts<Array[Symbol]>:: Additional imformations
      #
      # ==== Options
      # importer:: Can perform import
      # exporter:: Can perform export
      def self.Provider(name, *opts)
        Module.new do
          include Base
          include Base::Importer if opts.include? :importer
          include Base::Exporter if opts.include? :exporter
          
          def self.included(klass)
            Merb::Global::MessageProviders.register name, klass
          end
        end
      end
            # Merb-global is able to store the translations in different types of
      # storage. An interface betwean merb-global and those storages are
      # providers.
      #
      # Please note that it is not required to include this module - despite it
      # is recomended both as a documentation part and the more customized
      # error messages.
      module Base
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
          raise NoMethodError.new
                                 'method translate_to has not been implemented'
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
        # NoMethodError:: Raised by default implementation.
        #                 Should not be thrown.
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

        ##
        # Transfer data from importer into exporter
        #
        #
        #
        # ==== Parameters
        # importer<Importer>:: The provider providing the information
        # exporter<Exporter>:: The provider receiving the information
        def self.transfer(importer, exporter)
          exporter.export importer.import
        end
        
        ##
        # Importer is a provider through which one can iterate.
        # Therefore it is possible to import data from this source
        module Importer
          ##
          # This method import the data into a specified format from source.
          # The format is nearly dump of the current YAML format.
          #
          # ==== Returns
          # data<~each>::   Data in the specified format.
          #
          # ==== Raises
          # NoMethodError:: Raised by default implementation.
          #                 Should not be thrown.
          def import # TODO: Describe the format
            raise NoMethodError.new('method import has not been implemented')
          end
        end
        ##
        # Some sources are not only read-only but one can write to them.
        # The provider is exporter if it handles this sort of source.
        module Exporter
          ##
          # The method export the data from specified format into destination
          # The format is nearly dump of the current YAML format.
          #
          # ==== Parameters
          # data<~each>::   Data in the specified format.
          #
          # ==== Raises
          # NoMethodError:: Raised by default implementation.
          #                 Should not be thrown.
          def export(data) # TODO: Describe the format
            raise NoMethodError.new('method import has not been implemented')
          end
        end
      end
    end
  end
end
