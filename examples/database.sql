DROP TABLE IF EXISTS merb_global_languages;
CREATE TABLE merb_global_languages (
id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
name VARCHAR(50),
nplural INTEGER,
plural TEXT
);

DROP TABLE IF EXISTS merb_global_translations;
CREATE TABLE merb_global_translations (
language_id INTEGER NOT NULL,
msgid TEXT NOT NULL,
msgid_plural TEXT,
msgstr TEXT NOT NULL,
msgstr_index INTEGER,
PRIMARY KEY(language_id, msgid, msgstr_index));


CREATE UNIQUE INDEX unique_index_merb_global_languages_name
ON merb_global_languages (name);

INSERT INTO merb_global_languages (name, nplural, plural)
VALUES ("pl", 3, "(n==1?0:n%10>=2&&n%10<=4&&(n%100<10||n%100>=20)?1:2)");

INSERT INTO merb_global_translations (language_id, msgid, msgstr)
SELECT id, "Hi! Hello world!", "Cześć. Witaj świecie!"
FROM merb_global_languages
WHERE name = "pl";
