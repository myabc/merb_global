if defined? Merb::Plugins
  require 'merb_global/base'
  require 'merb_global/controller'

  Merb::Plugins.add_rakefiles 'merb_global/rake'
end
