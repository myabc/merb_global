require 'merb_global/base'

module Merb
  class Controller #:nodoc:
    include Merb::Global
    before do
      # Set up the language
      accept_language = self.request.env['HTTP_ACCEPT_LANGUAGE']
      self.lang = "en"
      unless accept_language.nil?
        accept_language = accept_language.split(',')
        accept_language.collect! {|lang| lang.delete " " "\n" "\r" "\t"}
        accept_language.reject! {|lang| lang.empty?}
        accept_language.collect! {|lang| lang.split ';q='}
        accept_language.collect! do |lang|
          if lang.size == 1
            [lang[0], 1.0]
          else
            [lang[0], lang[1].to_f]
          end
        end
        accept_language.sort! {|lang_a, lang_b| lang_a[1] <=> lang_b[1]}
        accept_language.collect! {|lang| lang[0]}
        accept_language.reject! do |lang|
          lang != '*' and not self.provider.support? lang
        end
        unless accept_language.empty?
          unless accept_language.last == '*'
            self.lang = accept_language.last
          else
            accept_language.pop
            self.lang = (self.provider.choose(accept_language) || "en")
          end
        end
      end
    end
  end
end
