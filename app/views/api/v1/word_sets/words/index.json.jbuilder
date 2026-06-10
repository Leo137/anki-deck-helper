# frozen_string_literal: true

json.words @words do |word|
  json.partial! 'api/v1/words/word', word:, language: @language
end

json.pagination @pagination
