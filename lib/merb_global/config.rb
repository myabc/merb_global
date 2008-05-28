module Merb
  module Global
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
