class TranslationMigrationGenerator < Merb::GeneratorBase
  protected :banner

  def initialize runtime_args, runtime_options = {}
    runtime_args.push ''
    super
    @name = 'translations'
  end

  def mainfest
    record do |m|
      m.directory 'schema/migrations'
      highest_migration = Dir[Dir.pwd+'/schema/migrations/*'].map do |f|
        File.basename(f) =~ /^(\d+)/
        $1
      end.max
      filename = format "%03d_%s", (highest_migration.to_i+1), @name.snake_case
      m.template 'translation_migration.erb',
                 "schema/migrations/#{filename}.rb"
      puts banner
    end
  end

  def banner
    <<-EOS
A migration to add translation tables to your database has been created.
Run 'rake sequel:db:migrate' to add the translations migration to your
database.

EOS
  end
end
