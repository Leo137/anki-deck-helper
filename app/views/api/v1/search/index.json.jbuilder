json.query @query

json.words @words do |word|
  json.partial! 'api/v1/search/word', word: word
end

json.word_sets @word_sets do |word_set|
  json.partial! 'api/v1/search/word_set', word_set: word_set
end

json.pagination do
  json.words do
    json.current_page @words.current_page
    json.total_pages @words.total_pages
    json.total_count @words.total_count
    json.per_page @words.limit_value
  end

  json.word_sets do
    json.current_page @word_sets.current_page
    json.total_pages @word_sets.total_pages
    json.total_count @word_sets.total_count
    json.per_page @word_sets.limit_value
  end
end
