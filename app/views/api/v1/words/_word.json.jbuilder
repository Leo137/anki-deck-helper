# frozen_string_literal: true

json.extract! word, :id, :content, :kana, :word_count
json.reading word.reading

json.tags word.merged_tags

json.frequencies word.word_frequencies do |word_frequency|
  json.table word_frequency.frequency_table.name
  json.frequency word_frequency.frequency
  json.ratio word_frequency.ratio_frequency
end
