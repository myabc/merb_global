module Merb
  module Global
    module Providers
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
      # Is there a way to mark static methods as private?
      @@provider_name = lambda do 
        Merb::Global.config :provider, 'gettext'
      end
      @@provider_loading = lambda do |provider|
        # Should it be like that or should the provider be renamed?
        require 'merb_global/providers/' + provider
        @@provider = eval "Merb::Global::Providers::#{provider.camel_case}.new"
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
