# Load the merb_global from current tree
Gem.clear_paths
Gem.path.unshift((Pathname(__FILE__).dirname + '../../../pkg').expand_path)
$LOAD_PATH.unshift((Pathname(__FILE__).dirname + '../../../lib').expand_path)

Merb::Router.prepare do |r|
  r.match('/').to(:controller => 'data_mapper_example', :action =>'index')
end

use_orm :datamapper
dependency 'merb_global'

Merb::Config.use { |c|
  c[:environment]         = 'production',
  c[:framework]           = {},
  c[:log_level]           = 'debug',
  c[:use_mutex]           = false,
  c[:session_store]       = 'cookie',
  c[:session_id_key]      = '_session_id',
  c[:session_secret_key]  = '5b587281e1b277c3e90f5de2e42e5125dc649837',
  c[:exception_details]   = true,
  c[:reload_classes]      = true,
  c[:reload_time]         = 0.5
}
