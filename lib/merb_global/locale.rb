require 'merb_global/base'
require 'thread'
require 'weakref'

class Thread
  attr_accessor :mg_locale
end

module Merb
  module Global
    class Locale
      attr_reader :language, :country

      def initialize(name)
        # TODO: Understand RFC 1766 fully
        @language, @country = name.split('-')
      end

      def any?
        language == '*' && country.nil?\
      end

      def base_locale
        if not @country.nil?
          Locale.new(@language)
        else
          nil
        end
      end

      def to_s
        if country.nil?
          "#{@language.downcase}"
        else
          "#{@language.downcase}_#{@country.upcase}"
        end
      end

      if defined? RUBY_ENGINE and RUBY_ENGINE == "jruby"
        def java_locale
          require 'java'
          @java_locale ||=
            if @country.nil?
              java.util.Locale.new(@language.downcase)
            else
              java.util.Locale.new(@language.downcase, @country.upcase)
            end
        end
      else
        def java_locale
          nil
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

      class << self
        alias_method :pure_new, :new
        private :pure_new
      end

      @@current = {}
      @@current_mutex = Mutex.new
      # Create new locale object and returns it.
      # 
      # Please note that this method is cached.
      def self.new(name)
        return nil if name.nil?
        return name if name.is_a? Locale
        @@current_mutex.synchronize do
          begin
            n = @@current[name]
            if n.nil?
              n = pure_new(name)
              @@current[name] = WeakRef.new(n)
            else
              n = n.__getobj__
            end
            n
          rescue WeakRef::RefError
            n = pure_new(name)
            @@current[name] = WeakRef.new(n)
            n
          end
        end
      end

      def self.support?(locale)
        Merb::Global.config('locales', ['en']).include? locale.to_s
      end
      
      def self.choose(except)
        new((Merb::Global.config('locales', ['en']) - except.map{|e| e.to_s}).first)
      end
    end
  end
end
