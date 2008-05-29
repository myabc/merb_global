namespace :merb_global do
  task :merb_start do
    Merb.start_environment :adapter => 'runner',
                           :environment => ENV['MERB_ENV'] || 'development'
  end
  desc 'Create migration'
  task :migration => :merb_start do
    Merb::Global::Providers.provider.create!
  end
end
