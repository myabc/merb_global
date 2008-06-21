namespace :merb_global do
  task :merb_start do
    Merb.start_environment :adapter => 'runner',
                           :environment => ENV['MERB_ENV'] || 'development'
  end
  desc 'Create migration'
  task :migration => :merb_start do
    Merb::Global::Providers.provider.create!
  end
  desc 'Transfer the translations from one provider to another'
  task :transfer => :merb_start do
    from = Merb::Global.config 'source', 'gettext'
    into = Merb::Global.config 'provider', 'gettext'
    if from == 'gettext' and into == 'gettext'
      # Change po into mo files
    elsif from == into
      Merb.logger.error 'Tried transfer from and into the same provider'
    else
      from = Merb::Global::Providers[from]
      into = Merb::Global::Providers[into]
      Merb::Global::Provider.transfer from, into
    end
  end
end
