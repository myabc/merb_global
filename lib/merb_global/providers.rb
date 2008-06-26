require 'merb_global/providers/base'

module Merb
  module Global
    module Providers
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
            klass = "Merb::Global::Providers::#{provider.camel_case}"
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
            Merb::Global::Providers.register name, klass
          end
        end
      end
    end
  end
end
