json.partial! 'api/v1/words/word', word: @word

json.word_sets @word.word_sets do |word_set|
  json.extract! word_set, :id, :name
end

json.dictionary_entries @dictionary_entries do |entry|
  json.partial! 'api/v1/dictionary_entries/entry', entry: entry
end

