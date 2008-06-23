require 'gettext'
require 'treetop'
require 'pathname'

# I'm not sure if it is the correct way of doing it.
# As far it seems to be simpler.
class Thread #:nodoc:
  def gettext_context
    @gettext_context ||= Merb::Global::Providers::Gettext::GettextContext.new
  end
end

module Merb
  module Global
    module Providers
      class Gettext #:nodoc: all
        include Merb::Global::Provider
        include Merb::Global::Provider::Importer
        
        def translate_to(singular, plural, opts)
          context = Thread.current.gettext_context
          context.set_locale opts[:lang], true
          unless plural.nil?
            context.ngettext singular, plural, opts[:n]
          else
            context.gettext singular
          end
        end

        def support?(lang)
          lang == 'en' ||
            File.exist?(File.join(Merb::Global::Providers.localedir, lang))
        end

        def create!
          File.mkdirs Merb::Global::Providers.localedir
        end

        def choose(except)
          dir = Dir[Merb::Global::Providers.localedir + '/*/']
          dir.collect! {|p| File.basename p}
          dir << 'en'
          dir.reject! {|lang| except.include? lang}
          dir.first
        end

        def import(exporter, export_data)
          Treetop.load(Pathname(__FILE__).dirname.expand_path.to_s +
                       '/gettext')
          parser = Merb::Global::Providers::GetTextParser.new
          Dir[Merb::Global::Providers.localedir + '/*.po'].each do |file|
            lang_name = File.basename file, '.po'
            lang_tree = nil
            open file do |data|
              lang_tree = parser.parse data.read
            end
            opts = (lang_tree.to_hash)[''].split("\n")
            plural_line = nil
            for l in opts
              if l[0..."Plural-Forms:".length] == "Plural-Forms:"
                plural_line = l
                break
              end
            end
            plural_line =
              plural_line["Plural-Forms:".length...plural_line.length]
            plural_line = plural_line[0...plural_line.length-1]
            plural_line = plural_line.gsub(/[[:space:]]/, '').split(/[=;]/, 4)
            plural_line = Hash[*plural_line]
            exporter.export_language export_data, lang_name,
                                     plural_line['nplurals'].to_i,
                                     plural_line['plural'] do |lang_data|
              lang_tree.visit do |msgid, msgid_plural, msgstr, index|
                exporter.export_string lang_data, msgid, msgid_plural,
                                                  index, msgstr
              end
            end
          end
        end

        class GettextContext
          include ::GetText
          bindtextdomain Merb::Global.config([:gettext, :domain], 'merbapp'),
                         Merb::Global::Providers.localedir
          public :set_locale, :ngettext, :gettext
        end
      end
    end
  end
end
