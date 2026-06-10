# frozen_string_literal: true

json.extract! word_set, :id, :name
json.words_count word_set.words.count
