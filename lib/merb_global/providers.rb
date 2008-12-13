module Merb
  module Global
    module Providers
      def self.included(mod) #:nodoc:
        mod.module_eval do
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
                require "merb_global/#{self.name.split("::").last.snake_case}/#{provider.to_s}"
                @@providers[provider.to_sym] = self.const_get(provider.camel_case).new
              end
            end
            @@providers[provider.to_sym]
          end
          # Registers the class under the given name
          # 
          # ==== Parameters
          # name<~to_sym>:: Name under which it is registered
          # klass<Class>:: Class of the provider
          def self.register(name, klass)
            @@providers_classes[name.to_sym] = klass
          end
        end
      end
    end
  end
end
