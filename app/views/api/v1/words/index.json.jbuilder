# frozen_string_literal: true

json.array! @words do |word|
  json.partial! 'api/v1/words/word', word:
end
