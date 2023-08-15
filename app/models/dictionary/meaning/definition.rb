class Dictionary::Meaning::Definition < ApplicationRecord
  self.table_name = 'dictionary_meaning_definitions'

  belongs_to :dictionary_meaning, class_name: 'Dictionary::Meaning', foreign_key: 'dictionary_meaning_id'
end
