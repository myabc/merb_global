module Merb
  module Global
    module Providers
      @@providers = {}
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
          require 'merb_global/providers/' + provider
          klass = "Merb::Global::Providers::#{provider.camel_case}"
          @@providers[provider.to_sym] = eval "#{klass}.new"
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
    end
  end
end
