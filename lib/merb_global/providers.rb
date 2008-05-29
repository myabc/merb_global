module Merb
  module Global
    module Providers
      @@provider_name = lambda do
          Merb::Global.config :provider, 'gettext'
        end
      @@provider_loading = lambda do |provider|
        require 'merb_global/providers/' + provider
        @@provider = eval "Merb::Global::Providers::#{provider.camel_case}.new"
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
        @@provider ||= @@provider_loading.call @@provider_name.call
      end
    end
  end
end
