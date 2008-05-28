module Merb
  module Global
    # call-seq:
    #    config(key)                        => value
    #    config([key1, key2, ...])          => value
    #    config(key, default)               => value
    #    config([key1, key2, ...], default) => value
    #
    # Lookup the configuration
    # ==== Params
    # key<Symbol>:: A key
    # keys<Array[Symbol]>:: Keys
    # default<Object>:: A default value
    #
    # ==== Returns
    # value<Object>:: Object read from configuration or default
    #
    # ==== Examples
    # <tt>Merb::Global.config [:gettext, :domain], 'merbapp'</tt>
    def self.config(keys, default = nil)
      keys = [keys] unless keys.is_a? Array
      current = Merb::Plugins.config[:merb_global]
      while current.respond_to?(:[]) and not keys.empty?
        current = current[keys.shift]
      end
      (keys.empty? and not current.nil?) ? current : default
    end
  end
end
