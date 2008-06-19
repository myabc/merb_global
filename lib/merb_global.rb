require 'pathname'

if defined? Merb::Plugins
  require Pathname(__FILE__).dirname.expand_path + 'merb_global/base'
  require Pathname(__FILE__).dirname.expand_path + 'merb_global/controller'

  Merb::Plugins.add_rakefiles(Pathname(__FILE__).dirname.expand_path + 'merb_global/merbrake')
end
