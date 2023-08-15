# README

This README would normally document whatever steps are necessary to get the
application up and running.


# Install

docker volume create --name=word-tracker-gems
docker-compose up


# Commands

```
FrequencyTableImporter.new('bccwj', 'frequency-tables/bccwj.json').call
FrequencyTableImporter.new('jpdb', 'frequency-tables/jpdb.json').call
FrequencyTableImporter.new('wikipedia', 'frequency-tables/wikipedia.json').call
WordSetImporter.new('comprehensive-japanese', 'word-lists/comprehensive-japanese').call
WordSetImporter.new('kindle', 'word-lists/kindle').call
FrequencyCalculator.new('bccwj', Word.all).call
FrequencyCalculator.new('jpdb', Word.all).call
FrequencyCalculator.new('wikipedia', Word.all).call

frequency_table = FrequencyTable.find_by(name: 'bccwj')
Word.by_frequency_table(frequency_table)

word_set = WordSet.find_by(name: 'kindle')
Word.by_word_sets([word_set])

WordPriorityEstimator.new(Word.all, FrequencyTable.all).call

```
