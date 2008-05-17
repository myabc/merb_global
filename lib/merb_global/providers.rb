module Merb
  module Global
    module Providers
      # Probably there's better place for this startup code. However it's
      # should work
      provider = 'gettext'
      unless Merb::Plugins.config[:merb_global].nil?
        unless Merb::Plugins.config[:merb_global][:provider].nil?
          provider = Merb::Plugins.config[:merb_global][:provider]
        end
      end
      # Should it be like that or should the provider be renamed?
      require 'merb_global/providers/' + provider.gsub(/_/, '')
      @@provider = eval("Merb::Global::Providers::#{provider.camel_case}.new")
      # call-seq:
      #     provider => provider
      #
      # Returns the provider of required type
      #
      # ==== Returns
      # provider<Provider>:: Returns provider
      def self.provider
        @@provider
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
        localedir = nil
        unless Merb::Plugins.config[:merb_global].nil?
          if not Merb::Plugins.config[:merb_global][:localedir].nil?
            localedir = Merb::Plugins.config[:merb_global][:localedir]
          elsif Merb::Plugins.config[:merb_global][:flat]
            localedir = 'locale'
          end
        end
        localedir ||= File.join('app', 'locale')
        File.join Merb.root, localedir
      end
    end
  end
end
