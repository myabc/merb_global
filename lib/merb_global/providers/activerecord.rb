require 'activerecord'
# As far as I understend we need it to have compostie keys
# However it may be better idea to drop them.
# As far I implement it in this way - then we will see
require 'composite_primary_keys' # As far as I understend we need

module Merb
  module Global
    module Providers
      class Activerecord #:nodoc:
        def translate_to singular, plural, opts
          language = Language.find :first,
                                   :conditions => {:name => opts[:lanf]}
          n = Plural.which_form n, language.plural
          Translation.find [language.pk, singular.hash, n]
        end
        class Language < ActiveRecord::Base
        end
        class Translation < ActiveRecord::Base
          set_primary_keys :language_id, :msgid_hash, :msgstr_index
        end
      end
    end
  end
end
