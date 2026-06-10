# frozen_string_literal: true

json.array! @word_sets do |word_set|
  json.extract! word_set, :id, :name, :created_at, :updated_at
  json.words_count word_set.words_count
end
