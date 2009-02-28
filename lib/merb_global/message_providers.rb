require 'merb_global/providers'

module Merb
  module Global
    module MessageProviders
      include Providers
      # call-seq:
      #     localedir => localdir
      #
      # Returns the directory where locales are stored for file-backed
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
        @@provider ||= self[Merb::Global.config(:message_provider, 'gettext')]
      end
      # Merb-global is able to store the translations in different types of
      # storage. An interface between merb_global and those storages are
      # providers.
      #
      # Please note that it is not required to include this module - despite it
      # is recomended both as a documentation part and the more customized
      # error messages.
      module Base
        # call-seq:
        #     localize(singular, plural, opts) => translated
        #
        # Translate string using specific provider.
        # It should be overloaded by the implementor.
        #
        # Do not use this method directly - use Merb::Global._ instead
        #
        # ==== Parameters
        # singular<String>:: A string to translate
        # plural<String>:: A plural form of string (nil if only singular)
        # n<Fixnum>:: A number of objects
        # locale<Locale>:: A locale to which translate
        #
        # ==== Returns
        # translated<String>:: A translated string
        #
        # ==== Raises
        # NoMethodError:: Raised by default implementation. Should not be thrown.
        def localize(singular, plural, n, locale)
          raise NoMethodError.new('method localize has not been implemented')
        end
        # This method creates basic files and/or directory structures
        # (for example it adds migration) needed for provider to work.
        #
        # It is called from Rakefile.
        def create!
          raise NoMethodError.new('method create! has not been implemented')
        end
        ##
        # Transfer data from importer into exporter
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
    # Perform the registration
    #
    # ==== Parameters
    # provider_name<~to_sym>:: Name under which it is registred
    # opts<Array[Symbol]>:: Additional imformations
    #
    # ==== Options
    # importer:: Can perform import
    # exporter:: Can perform export
    def self.MessageProvider(provider_name, *opts)
      Module.new do
        @@mg_message_provider_name = provider_name
        
        include Merb::Global::MessageProviders::Base
        if opts.include? :importer
          include Merb::Global::MessageProviders::Base::Importer
        end
        if opts.include? :exporter
          include Merb::Global::MessageProviders::Base::Exporter
        end
        
        def self.included(klass)
          Merb::Global::MessageProviders.register @@mg_message_provider_name,
                                                  klass
        end
      end
    end
  end
end
