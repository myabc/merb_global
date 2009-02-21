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

      #
      # This method checks if the locale is 'wildcard' locale. I.e.
      # if any locale will suit
      #
      def any?
        language == '*' && country.nil?
      end

      #
      # This method returns the parent locale - for locales for countries
      # (such as en_GB) it returns language(en). For languages it returns nil.
      #
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
        #
        # This method return corresponding java locales caching the result.
        # Please note that if used outside jruby it returns nil.
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
      
      def self.parse(header) #:nodoc:
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
        header.sort! {|lang_a, lang_b| lang_b[1] <=> lang_a[1]} # sorting by decreasing quality
        header.collect! {|lang| Locale.new(lang[0])}
      end

      def self.from_accept_language(accept_language) #:nodoc:
        unless accept_language.nil?
          accept_language = Merb::Global::Locale.parse(accept_language)
          accept_language.each_with_index do |lang, i|
            if lang.any?
              # In this case we need to choose a locale that is not in accept_language[i+1..-1]
              return Merb::Global::Locale.choose(accept_language[i+1..-1])
            elsif Merb::Global::Locale.support? lang
              return lang
            end
            lang = lang.base_locale
            return lang if lang && Merb::Global::Locale.support?(lang)
          end
        end
      end

      # Returns current locale
      def self.current
        Thread.current.mg_locale
      end

      # Sets the current locale
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

      # Checks if the locale is supported
      def self.support?(locale)
        supported_locales.include? locale.to_s
      end
      
      # Lists the supported locale
      def self.supported_locales
        Merb::Global::config('locales', ['en'])
      end
      
      # Chooses one of the supported locales which is not in array given as
      # argument
      def self.choose(except)
        new((supported_locales - except.map{|e| e.to_s}).first)
      end
    end
  end
end
