module Merb
  module Global
    module Providers
      def self.provider
        # provider = 'gettext'
        provider = 'mock'
        unless Merb::Plugins.config[:merb_global].nil?
          unless Merb::Plugins.config[:merb_global][:provider].nil?
            provider = Merb::Plugins.config[:merb_global][:provider]
          end
        end
        require 'merb_global/providers/' + provider
        eval "Merb::Global::Providers::#{provider.capitalize}.new"
      end
    end
  end
end
