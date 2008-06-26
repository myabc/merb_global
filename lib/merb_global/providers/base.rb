module Merb
  module Global
    module Providers
      # Merb-global is able to store the translations in different types of
      # storage. An interface betwean merb-global and those storages are
      # providers.
      #
      # Please note that it is not required to include this module - despite it
      # is recomended both as a documentation part and the more customized
      # error messages.
      module Base
        # call-seq:
        #     translate_to(singular, plural, opts) => translated
        #
        # Translate string using specific provider.
        # It should be overloaded by the implementator.
        #
        # Do not use this method directly - use Merb::Global._ instead
        #
        # ==== Parameters
        # singular<String>:: A string to translate
        # plural<String>:: A plural form of string (nil if only singular)
        # opts<Hash>:: An options hash (see below)
        #
        # ==== Options (opts)
        # :lang<String>:: A language to translate on
        # :n<Fixnum>:: A number of objects
        #
        # ==== Returns
        # translated<String>:: A translated string
        #
        # ==== Raises
        # NoMethodError:: Raised by default implementation. Should not be thrown.
        def translate_to(singular, plural, opts)
          raise NoMethodError.new
                                 'method translate_to has not been implemented'
        end
        
        # call-seq:
        #     support?(lang) => supported
        #
        # Checks if the language is supported (i.e. if the translation exists).
        #
        # In normal merb app the language is checked automatically in controller
        # so probably you don't have to use this method
        #
        # ==== Parameters
        # lang<String>:: A code of language
        #
        # ==== Returns
        # supported<Boolean>:: Is a program translated to this language
        #
        # ==== Raises
        # NoMethodError:: Raised by default implementation.
        #                 Should not be thrown.
        def support?(lang)
          raise NoMethodError.new('method support? has not been implemented')
        end
        
        # This method creates basic files and/or directory structures
        # (for example it adds migration) needed for provider to work.
        #
        # It is called from Rakefile.
        def create!
          raise NoMethodError.new('method create! has not been implemented')
        end
        
        # This method choos an supported language except those form the list
        # given. It may fallback to english if none language can be found
        # which agree with those criteria
        def choose(except)
          raise NoMethodError.new('method choose has not been implemented')
        end

        ##
        # Transfer data from importer into exporter
        #
        # ==== Parameters
        # importer<Importer>:: The provider providing the information
        # exporter<Exporter>:: The provider receiving the information
        def self.transfer(importer, exporter)
          exporter.export do |export_data|
            importer.import(exporter, export_data)
          end
        end
        
        ##
        # Importer is a provider through which one can iterate.
        # Therefore it is possible to import data from this source
        module Importer
          ##
          # This method iterates through the data and calles the export method
          # of exporter
          #
          # ==== Parameters
          # exporter<Exporter>:: Exporter to which it should be exported
          # export_data:: Data to pass in calles
          #
          # ==== Raises
          # NoMethodError:: Raised by default implementation.
          #                 Should not be thrown.
          def import(exporter, export_data)
            raise NoMethodError.new('method import has not been implemented')
          end
        end
        ##
        # Some sources are not only read-only but one can write to them.
        # The provider is exporter if it handles this sort of source.
        module Exporter
          ##
          # This method handles all transaction stuff that is needed.
          # It also should do a initialization and/or cleanup of all resources
          # needed specificly to the transfer as well as the final
          # flush of changes.
          # ==== Yields
          # exported:: A data needed for transfer
          def export # Better name needed
            Merb.logger.error('No transaction has been set by exporter')
            yield nil
          end
          ##
          # This method exports a single message. Please note that the calles
          # may be not in any particular order.
          # ==== Parameters
          # language:: Language data (yielded by Language call)
          # msgid<String>:: Orginal string
          # msgid_plural<String>:: Orginal plural string
          # msgstr<String>:: The translation
          # msgstr_index<Integer>:: The number of form (nil if only singular)
          def export_string(language, msgid, msgid_plural,
                                      msgstr, msgstr_index)
            raise NoMethodError.new('method export has not been implemented')
          end
          ##
          # This method export an language. It is guaranteed to be called
          # before any of the messages will be exported.
          #
          # ==== Parameters
          # export_data:: Data given from transfer
          # language<String>:: Language call
          # nplural<Integer>:: Number of forms
          # plural<String>:: Format of plural
          # ==== Yields
          # language:: The data about language
          def export_language(export_data, language, nplural, plural)
            raise NoMethodError.new('method export has not been implemented')
          end
        end
      end
    end
  end
end
