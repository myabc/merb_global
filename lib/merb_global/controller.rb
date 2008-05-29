require 'merb_global/base'

module Merb
  class Controller 
    include Merb::Global
    class_inheritable_accessor :_language

    before do
      # Set up the language
      accept_language = self.request.env['HTTP_ACCEPT_LANGUAGE']
      self.lang = params[:language] ||
        (self._language && self._language.call) ||
        begin
          unless accept_language.nil?
            accept_language = accept_language.split(',')
            accept_language.collect! {|lang| lang.delete ' ' "\n" "\r" "\t"}
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
                accept_language.last
              else
                accept_language.pop
                self.provider.choose accept_language
              end
            end
          end
        end || 'en'
    end
    # Sets the language of block.
    #
    # The block should return language or nil if other method should be used
    # to determine the language
    def self.language &block
      self._language = block
    end
  end
end
