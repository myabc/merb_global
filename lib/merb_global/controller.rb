require 'merb_global/base'

module Merb
  class Controller
    include Merb::Global

    class_inheritable_accessor :_mg_locale

    before do
      # Set up the language
      accept_language = self.request.env['HTTP_ACCEPT_LANGUAGE']
      Merb::Global::Locale.current =
        Merb::Global::Locale.new(params[:locale]) ||
        (self._mg_locale &&
         Merb::Global::Locale.new(self.instance_eval(&self._mg_locale))) ||
        begin
          unless accept_language.nil?
            accept_language = Merb::Global::Locale.parse(accept_language)
            accept_language.collect! do |lang|
              if lang.any?
                lang
              elsif Merb::Global::MessageProviders.provider.support? lang
                lang
              else
                lang = lang.base_locale
                if not lang.nil? and Merb::Global::MessageProviders.provider.support? lang
                  lang
                else
                  nil
                end
              end
            end
            accept_language.reject! {|lang| lang.nil?}
            unless accept_language.empty?
              unless accept_language.last.any?
                accept_language.last
              else
                accept_language.pop
                Merb::Global::MessageProviders.provider.choose accept_language
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
    # Please note that this method is deprecated and the preferred method is
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
  end
end
