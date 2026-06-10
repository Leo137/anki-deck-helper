json.text entry.text

json.readings entry.readings.select(&:is_kana?).map(&:text).uniq

json.senses entry.meanings do |meaning|
  json.tags meaning.misc_tags.map(&:code) +
             meaning.fields.map(&:code) +
             meaning.part_of_speeches.map(&:code)
  json.definitions meaning.definitions.map(&:text)
end
