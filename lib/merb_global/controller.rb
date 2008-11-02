require 'merb_global/base'

module Merb
  class Controller
    include Merb::Global

    class_inheritable_accessor :_mg_locale

    before do
      # Set up the language
      accept_language = self.request.env['HTTP_ACCEPT_LANGUAGE']
      self.lang = Merb::Global::Locale.new(params[:locale]) ||
        self._mg_get_locale() ||
        begin
          unless accept_language.nil?
            accept_language = Merb::Global::Locale.parse(accept_language)
            accept_language.collect! do |lang|
              if lang.any?
                lang
              elsif self.message_provider.support? lang
                lang
              else
                lang = lang.base_locale
                if self.message_provider.support? lang
                  lang
                else
                  nil
                end
              end
            end
            accept_language.reject! {|lang| lang.nil?}
            unless accept_language.empty?
              unless accept_language.last.any?
                accept_language.any?
              else
                accept_language.pop
                self.message_provider.choose accept_language
              end
            end
          end
        end || Merb::Global::Locale.new('en')
    end

    # Sets the language of block.
    #
    # The block should return language or nil if other method should be used
    # to determine the language
    #
    # Please note that this method is deprecated and the prefereed method is
    # locale.
    def self.language(&block)
      self._mg_locale = block
    end
    # Sets the language of block.
    #
    # The block should return language or nil if other method should be used
    # to determine the language
    def self.locale(&block)
      self._mg_locale = block
    end
    private :_mg_get_locale
    def _mg_get_locale #:nodoc:
      if not _mg_locale.nil?
        locale = self.instance_eval(_mg_locale)
        if locale.is_a? Merb::Global::Locale
          locale
        else
          Merb::Global::Locale.new(locale)
        end
      end
    end
  end
end
