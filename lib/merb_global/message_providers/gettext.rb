require 'gettext'
require 'treetop'
require 'pathname'

class Merb::Global::Locale #:nodoc:
  def _mg_gettext
    @mg_gettext ||= Merb::Global::MessageProviders::Gettext::GettextContext.new
  end
end

module Merb
  module Global
    module MessageProviders
      class Gettext #:nodoc: all
        include Merb::Global::MessageProviders::Base
        include Merb::Global::MessageProviders::Base::Importer
        include Merb::Global::MessageProviders::Base::Exporter

        def localize(singular, plural, n, locale)
          context = locale._mg_gettext
          context.set_locale locale.to_s
          unless plural.nil?
            context.ngettext singular, plural, n
          else
            context.gettext singular
          end
        end

        def create!
          File.mkdirs Merb::Global::MessageProviders.localedir
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
            open file do |f|
              lang_tree = parser.parse f.read
            end
            # Put the parsed file in data
            data[lang_name] = lang_tree.to_hash
            # Remove the metadata to futher managing
            opts = data[lang_name].delete('')[nil].split("\n")
            # Find the line about plural line
            plural_line = nil
            for l in opts
              if l[0..."Plural-Forms:".length] == "Plural-Forms:"
                plural_line = l
                break
              end
            end
            # Remove the "Plural-Forms:" from the beginning...
            plural_line =
              plural_line["Plural-Forms:".length...plural_line.length]
            # and ; from end
            plural_line = plural_line[0...plural_line.length-1]
            # Split the line and build the hash
            plural_line = plural_line.gsub(/[[:space:]]/, '').split(/[=;]/, 4)
            # And change the plural and nplurals into :plural and :nplurals
            plural_line[2] = :plural
            plural_line[0] = :nplural
            # Adn the nplural value into integer
            plural_line[1] = plural_line[1].to_i
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
            end
            lang_dir = File.join(Merb::Global::MessageProviders.localedir,
                                 lang, 'LC_MESSAGES')
            FileUtils.mkdir_p lang_dir
            domain = Merb::Global.config([:gettext, :domain], 'merbapp')
            `msgfmt #{lang_file} -o #{lang_dir}/#{domain}.mo`
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
