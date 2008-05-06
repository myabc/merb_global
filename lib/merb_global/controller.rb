require 'merb_global/base'

module Merb
  class Controller #:nodoc:
    include Merb::Global
    before do
      accept_language = self.request.env['HTTP_ACCEPT_LANGUAGE'].split(',')
      accept_language.collect! {|lang| lang.delete " " "\n" "\r" "\t"}
      accept_language.reject! {|lang| lang.empty?}
      accept_language.collect! {|lang| lang.split ';'}
      accept_language.collect! do |lang|
        if lang.is_a? String
          [lang, 1.0]
        else
          [lang[0], lang[1].to_f]
        end
      end
      accept_language.sort! {|lang_a, lang_b| lang_a[1] <=> lang_b[1]}
      until accept_language.empty?
        clang = accept_language.pop[0]
        if self.provider.supported? clang
          self.lang = clang
          break
        end
      end
      self.lang = "en"
    end
  end
end
