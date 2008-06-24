require 'fileutils'

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
      Dir[Merb::Global::Providers.localedir + '/*.po'].each do |file|
        lang = File.basename file, '.po'
        lang_dir = File.join(Merb::Global::Providers.localedir,
                             lang, 'LC_MESSAGES')
        FileUtils.mkdir_p lang_dir
        domain = Merb::Global.config([:gettext, :domain], 'merbapp')
        `msgfmt #{file} -o #{lang_dir}/#{domain}.mo`
      end
    elsif from == into
      Merb.logger.error 'Tried transfer from and into the same provider'
    else
      from = Merb::Global::Providers[from]
      into = Merb::Global::Providers[into]
      Merb::Global::Provider.transfer from, into
    end
  end

end
