require 'merb_global/providers.rb'

module Merb
  module Global
    attr_writer :lang, :provider
    def lang
      @lang ||= ENV['LC_ALL'].split('.')[0]
    end
    def provider
      # @provider ||= Merb::Global::Providers::Gettext
      @provider ||= Merb::Global::Providers::Mock.new
    end
    def _ cstring, lang = self.lang
      self.provider.translate_to cstring, lang
    end
  end
end
