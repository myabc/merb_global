require 'sequel'
require 'benchmark'

DB = Sequel.connect ARGV[0]

DB.create_table! :languages1 do
  primary_key :id
  varchar  :name,         :size => 16,           :unique => true
  varchar  :plural,       :size => 128
end

DB.create_table! :translations1 do
  primary_key [:language_id, :msgid_hash, :msgstr_index]
  foreign_key :language_id, :languages1, :null => false
  integer     :msgid_hash,   :null => false
  text        :msgstr,       :null => false
  integer     :msgstr_index
end

DB.create_table! :languages2 do
  primary_key :id
  varchar  :name,         :size => 16,           :unique => true
  varchar  :plural,       :size => 128
end

DB.create_table! :translations2 do
  primary_key [:language_id, :msgid, :msgstr_index]
  foreign_key :language_id, :languages2, :null => false
  text        :msgid,        :null => false
  text        :msgstr,       :null => false
  integer     :msgstr_index
end

DB.create_table! :languages3 do
  primary_key :id
  varchar  :name,         :size => 16,           :unique => true
  varchar  :plural,       :size => 128
end

drop_table :original3 rescue nil
DB << "CREATE TABLE original3 (id INTEGER PRIMARY KEY, msgid TEXT)"

DB.create_table! :translations3 do
  primary_key [:language_id, :original_id, :msgstr_index]
  foreign_key :language_id, :languages3, :null => false
  foreign_key :original_id, :original3, :null => false
  text        :msgstr,       :null => false
  integer     :msgstr_index
end

$chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
def rand_string size
  (0...size).collect { $chars[Kernel.rand($chars.length)] }.join
end

$original = []
128.times { $original << rand_string(32) }
$original.sort!.uniq!
$translations = {}
$plurals = {}
3.times do
  lang_name = rand_string(2)
  $translations[lang_name] = lang = {}
  $plurals[lang_name] = rand_string(8)
  $original.each do |orig|
    lang[orig] = rand_string(32)
  end
end

$languages = $plurals.keys
def rand_language
  $languages[Kernel.rand($languages.length)]
end

def rand_original
  $original[Kernel.rand($original.length)]
end

puts 'Export'
Benchmark.bm(22) do |bm|
  bm.report('Original 0.0.3:') do
    $translations.each do |lang, trans|
      lang_id = (DB[:languages1] << {:name => lang, :plural => $plurals[lang]})
      trans.each do |original, translation|
        DB[:translations1] << {
          :language_id => lang_id,
          :msgid_hash => original.hash,
          :msgstr => translation
        }
      end
    end
  end
  bm.report('With string inside:') do
    $translations.each do |lang, trans|
      lang_id = (DB[:languages2] << {:name => lang, :plural => $plurals[lang]})
      trans.each do |original, translation|
        DB[:translations2] << {
          :language_id => lang_id,
          :msgid => original,
          :msgstr => translation
        }
      end
    end
  end
  bm.report('With separate strings:') do
    $original.each do |original|
      DB[:original3] << {:id => original.hash, :msgid => original}
    end
    $translations.each do |lang, trans|
      lang_id = (DB[:languages3] << {:name => lang, :plural => $plurals[lang]})
      trans.each do |original, translation|
        DB[:translations3] << {
          :language_id => lang_id,
          :original_id => original.hash,
          :msgstr => translation
        }
      end
    end
  end
end

$search = (0...1024).collect {[rand_language, rand_original]}

puts ''
puts 'Searching'
Benchmark.bm(22) do |bm|
  bm.report('Original 0.0.3:') do
    $search.each do |arr|
      _lang, _orig = *arr
      lang = DB[:languages1].filter(:name => _lang).first[:id]
      trans = DB[:translations1].filter(:language_id => lang,
                                        :msgid_hash => _orig.hash,
                                        :msgstr_index => nil).first[:msgstr]
    end
  end
  bm.report('With string inside:') do
    $search.each do |arr|
      _lang, _orig = *arr
      lang = DB[:languages2].filter(:name => _lang).first[:id]
      trans = DB[:translations2].filter(:language_id => lang,
                                        :msgid => _orig,
                                        :msgstr_index => nil).first[:msgstr]
    end
  end
  bm.report('With separate strings:') do
    $search.each do |arr|
      _lang, _orig = *arr
      lang = DB[:languages3].filter(:name => _lang).first[:id]
      trans = DB[:translations3].filter(:language_id => lang,
                                        :original_id => _orig.hash,
                                        :msgstr_index => nil).first[:msgstr]
    end
  end
end

puts ''
puts 'Import'
Benchmark.bm(22) do |bm|
  bm.report('With string inside:') do
    DB[:languages2].each do |lang|
      DB[:translations2].each do |trans|
        [lang[:name], trans[:msgid], trans[:msgstr], trans[:msgstr_index]]
      end
    end
  end
  bm.report('With separate strings:') do
    DB[:languages3].each do |lang|
      DB[:translations3].each do |trans|
        orig = DB[:original3].filter(:id => trans[:original_id]).first[:msgid]
        [lang[:name], orig, trans[:msgstr], trans[:msgstr_index]]
      end
    end
  end
end
