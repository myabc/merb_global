require 'merb_global/base'

class Thread
  attr_accessor :mg_locale
end

module Merb
  module Global
    class Locale
      attr_reader :language, :country
      
      def initialize(name)
        # TODO: Understend RFC 1766 fully
        language, country = name.split('-')
      end

      def any?
        language == '*' && country.nil?\
      end

      def base_locale
        Locale.new(language)
      end

      def to_s
        if country.nil?
          "#{language}"
        else
          "#{language}-#{country}"
        end
      end
      
      def self.parse(header)
        header = header.split(',')
        header.collect! {|lang| lang.delete ' ' "\n" "\r" "\t"}
        header.reject! {|lang| lang.empty?}
        header.collect! {|lang| lang.split ';q='}
        header.collect! do |lang|
          if lang.size == 1
            [lang[0], 1.0]
          else
            [lang[0], lang[1].to_f]
          end
        end
        header.sort! {|lang_a, lang_b| lang_a[1] <=> lang_b[1]}
        header.collect! {|lang| lang[0]}
        return header.collect! {|lang| Locale.new(lang)}
      end
      
      def self.current
        Thread.current.mg_locale
      end

      def self.current=(new_locale)
        Thread.current.mg_locale = new_locale
      end
    end
  end
end
