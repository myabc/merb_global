MerbGlobal README
=================

A plugin for the Merb framework providing Localization (L10n) and 
Internationalization (i18n) support.
 
merb\_global will have the following feature set:

 * support for model (content) localization
    - by default, localization stored in the database
        - with DataMapper   (targeted 0.1)
        - with ActiveRecord (targeted 0.2)
        - with Sequel ORM   
    - and, with a choice of strategies in each case:
        - single-table  (c.f. globalize RoR plugin)
        
                |title   |varchar(100)|
                |title_de|varchar(100)|
                |title_fr|varchar(100)|
                
        - joined-table for unlimited localizations (c.f. Symfony PHP)
    - or, alternatively localizations can be stored outside of the domain 
      model, UI Strings.
        
 * support for view (UI String) localization
    - choice of providers (po, yaml, database)
        
            Merb::Plugins.config[:merb_global] = {
              #:provider => "po",   # default
              :provider => 'yaml'
              #:provider => active_record
              #:provider => data_mapper
              #:provider => sequel
            }
            
    - for JRuby, wrapper allowing use of .properties files.
    
 * Extract, update for PO/POT files
 * Currency, Date and Language Helpers
        - stored either in the database, or for JRuby, wrappers around
        built-in functionality provided by java.util.Currency, java.util.Locale
        
 * support for localization of Merb generated code
 * support for non-English Inflectors.

Developer ReadMe
----------------

**REQUEST** : Your development support is very much appreciated. Please 
contact us below if you're interested in lending a hand with the development 
of this project.

Getting the Source
------------------

Performing a git clone on either of the following repositories will get you 
the latest source:

    git clone git://github.com/myabc/merb_global.git
    git clone git://gitorious.org/merb_global/mainline.git (on gitorious)

The following additional mirrors are available:

    git://repo.or.cz/merb_global.git
    http://repo.or.cz/r/merb_global.git

Installation and Setup
----------------------

    rake gem
    sudo gem install pkg/merb_global-0.0.1.gem

Licensing and Copyright
-----------------------

MerbGlobal is released under an **MIT License**. Copyright information, as 
well as a copy of the License may be found in the LICENSE file.

Support
-------

**WARNING REPEATED** : MerbGlobal at an early stage of its development. 
You should not use this code unless you're reasonably secure with both Ruby 
and Merb. That said, _please do get involved!_

Your best sources for support are currently the wiki, IRC or our mailing
list:

 * **MerbGlobal Wiki**:         <http://trac.ikonoklastik.com/merb_global/>
 * **MerbGlobal mailing list**: <http://groups.google.com/group/merb_global>
 * **MerbGlobal homepage**: _coming soon_
 * Contact the developers directly:
    - <alex@alexcolesportfolio.com> | myabc on #datamapper, #merb IRC
    - <uzytkownik2@gmail.com> | <xmpp:uzytkownik@jid.pl>
