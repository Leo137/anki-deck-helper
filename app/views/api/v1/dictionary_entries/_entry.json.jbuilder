# frozen_string_literal: true

json.text entry.text

json.readings entry.readings.select(&:is_kana?).map(&:text).uniq

meanings = if local_assigns[:dictionary_ids].present?
             entry.meanings.select { |meaning| dictionary_ids.include?(meaning.dictionary_id) }
           else
             entry.meanings
           end

json.senses meanings do |meaning|
  json.tags meaning.misc_tags.map(&:code) +
            meaning.fields.map(&:code) +
            meaning.part_of_speeches.map(&:code)
  json.definitions meaning.definitions.map(&:text)
end
