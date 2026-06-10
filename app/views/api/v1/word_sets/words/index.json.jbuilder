# frozen_string_literal: true

json.words @words do |word|
  json.partial! 'api/v1/words/word', word:
end

json.pagination @pagination
