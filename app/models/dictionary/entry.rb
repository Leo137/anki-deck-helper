# frozen_string_literal: true

class Dictionary
  class Entry < ApplicationRecord
    self.table_name = 'dictionary_entries'

    has_many :meanings, class_name: 'Dictionary::Meaning', foreign_key: 'dictionary_entry_id', dependent: :destroy
    has_many :readings, class_name: 'Dictionary::Reading', foreign_key: 'dictionary_entry_id', dependent: :destroy

    validates :text, presence: true

    def meanings_for(dictionary:)
      meanings.select { |meaning| meaning.dictionary_id == dictionary.id }
    end

    def to_s(dictionary: nil)
      senses = dictionary ? meanings_for(dictionary:) : meanings
      <<~TEXT
        #{readings.where(is_kana: true).map { |d| "<div class='reading'>#{d.text}</div>" }.join("\n")}
        <hr>#{senses.map(&:to_s).join("\n")}
      TEXT
    end
  end
end
