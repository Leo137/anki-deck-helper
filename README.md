# README

This README would normally document whatever steps are necessary to get the
application up and running.


# Install

docker volume create --name=word-tracker-gems
docker-compose up


# Commands

```
DictionaryImporter.new.call

FrequencyTableImporter.new('bccwj', 'frequency-tables/bccwj.json').call
FrequencyTableImporter.new('jpdb', 'frequency-tables/jpdb.json').call
FrequencyTableImporter.new('wikipedia', 'frequency-tables/wikipedia.json').call

WordSetImporter.new('comprehensive-japanese', 'word-lists/comprehensive-japanese').call
WordSetImporter.new('kindle', 'word-lists/kindle').call
WordSetImporter.new('shirokuma-cafe', 'word-lists/shirokuma-cafe').call
FrequencyCalculator.new('bccwj', Word.all).call
FrequencyCalculator.new('jpdb', Word.all).call
FrequencyCalculator.new('wikipedia', Word.all).call

frequency_table = FrequencyTable.find_by(name: 'bccwj')
Word.by_frequency_table(frequency_table)

word_set = WordSet.find_by(name: 'kindle')
Word.by_word_sets([word_set])

WordPriorityEstimator.new(Word.all, FrequencyTable.all).call
AnkiDeckGenerator.new(words, 'my_deck').call

```

To destroy things
```
Dictionary::Meaning::Definition.delete_all
Dictionary::Meaning::Field.delete_all
Dictionary::Meaning::MiscTag.delete_all
Dictionary::Meaning::PartOfSpeech.delete_all
Dictionary::Meaning.delete_all
Dictionary::Reading.delete_all
Dictionary::Entry.delete_all
```

Some styling
```
.card {
    font-family: arial;
    font-size: 20px;
    text-align: left;
    color: #222;
    background-color: white;
}

.reading{
  display: inline;
}

.h1 {
    font-family: arial;
    font-size: 30px;
    text-align: center;
    color: black;
    background-color: white;
}

.definition {
  display: inline;
  color: #888;
}

.tags {
font-size: 13px;
background: #222;
display: inline-block;
padding: 2px 5px;
border-radius: 6px;
text-align: center;
}
```
