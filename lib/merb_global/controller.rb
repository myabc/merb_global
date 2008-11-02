require 'merb_global/base'

module Merb
  class Controller
    include Merb::Global

    before do
      # Set up the language
      accept_language = self.request.env['HTTP_ACCEPT_LANGUAGE']
      self.lang = params[:language] ||
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
  end
end
