require 'merb_global/providers'

module Merb
  module Global
    module NumericProviders
      include Providers
      # call-seq:
      #     provider => provider
      #
      # Returns the provider of required type
      #
      # ==== Returns
      # provider<Provider>:: Returns provider
      def self.provider
        @@provider ||= self[Merb::Global.config(:numeric_provider, 'fork')]
      end
      # Merb-global is able to handle localization in different ways.
      # Providers are the interface.
      #
      # Please note that it is not required to include this module - despite it
      # is recomended both as a documentation part and the more customized
      # error messages.
      module Base
        ##
        # 
        # Localize date using format as in strftime
        def localize(lang, number)
          raise NoMethodError.new('method localize has not been implemented')
        end
      end
    end
    # Perform the registration
    #
    # ==== Parameters
    # name<~to_sym>:: Name under which it is registred
    def self.NumericProvider(provider_name)
      Module.new do
        @@rb_numeric_provider_name = provider_name
        include Merb::Global::NumericProviders::Base
        
        def self.included(klass)
          Merb::Global::NumericProviders.register @@rb_numeric_provider_name,
                                                  klass
        end
      end
    end
  end
end
