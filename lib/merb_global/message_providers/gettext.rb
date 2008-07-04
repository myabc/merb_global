require 'gettext'
require 'treetop'
require 'pathname'

# I'm not sure if it is the correct way of doing it.
# As far it seems to be simpler.
class Thread #:nodoc:
  def gettext_context
    @gettext_context ||= Merb::Global::MessageProviders::Gettext::GettextContext.new
  end
end

module Merb
  module Global
    module MessageProviders
      class Gettext #:nodoc: all
        include Merb::Global::MessageProviders::Base
        include Merb::Global::MessageProviders::Base::Importer
        include Merb::Global::MessageProviders::Base::Exporter

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
            File.exist?(File.join(Merb::Global::MessageProviders.localedir, lang))
        end

        def create!
          File.mkdirs Merb::Global::MessageProviders.localedir
        end

        def choose(except)
          dir = Dir[Merb::Global::MessageProviders.localedir + '/*/']
          dir.collect! {|p| File.basename p}
          dir << 'en'
          dir.reject! {|lang| except.include? lang}
          dir.first
        end

        def import
          Treetop.load(Pathname(__FILE__).dirname.expand_path.to_s +
                       '/gettext')
          parser = Merb::Global::MessageProviders::GetTextParser.new
          data = {}
          Dir[Merb::Global::MessageProviders.localedir +
              '/*.po'].each do |file|
            lang_name = File.basename file, '.po'
            lang_tree = nil
            open file do |data|
              lang_tree = parser.parse data.read
            end
            data[lang_name] = lang_tree.to_hash
            opts = data[lang_name][''].split("\n")
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
            data[lang_name].merge! Hash[*plural_line]
          end
          data
        end

        def export(data)
          data.each do |lang_name, lang|
            lang_file = File.join(Merb::Global::MessageProviders.localedir,
                                  lang_name + '.po')
            open(lang_file, 'w') do |po|
              po.puts <<EOF
msgid ""
msgstr ""
"Project-Id-Version: 0.0.1\\n"
"POT-Creation-Date: #{Time.now.strftime('%Y-%m-%d %H:%M%z')}\\n"
"PO-Revision-Date: #{Time.now.strftime('%Y-%m-%d %H:%M%z')}\\n"
"Last-Translator:  <user@example.com>\\n"
"Language-Team: Language type\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=#{lang[:nplurals]}; plural=#{lang[:plural]}\\n"
EOF
              
              lang.each do |msgid, msgstr_hash|
                po.puts ""
                po.puts "msgid \"#{msgid}\""
                if msgstr_hash[:plural]
                  po.puts "msgid_plural \"#{msgstr_hash[:plural]}\""
                  msgstr_hash.each do |msgstr_index, msgstr|
                    po.puts "msgstr[#{msgstr_index}] \"#{msgstr}\""
                  end
                else
                  po.puts "msgstr \"#{msgstr_hash[nil]}\""
                end
              end
              lang_dir = File.join(Merb::Global::MessageProviders.localedir,
                                   lang, 'LC_MESSAGES')
              FileUtils.mkdir_p lang_dir
              domain = Merb::Global.config([:gettext, :domain], 'merbapp')
              `msgfmt #{lang_file} -o #{lang_dir}/#{domain}.mo`
            end
          end
        end

        class GettextContext
          include ::GetText
          bindtextdomain Merb::Global.config([:gettext, :domain], 'merbapp'),
                         Merb::Global::MessageProviders.localedir
          public :set_locale, :ngettext, :gettext
        end
      end
    end
  end
end
