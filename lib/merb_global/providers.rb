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
      require 'merb_global/providers/' + provider
      @@provider = eval("Merb::Global::Providers::#{provider.capitalize}.new")
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
    end
  end
end
