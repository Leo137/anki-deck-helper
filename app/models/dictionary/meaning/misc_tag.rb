class Dictionary::Meaning::MiscTag < ApplicationRecord
  self.table_name = 'dictionary_meaning_misc_tags'

  belongs_to :dictionary_meaning, class_name: 'Dictionary::Meaning', foreign_key: 'dictionary_meaning_id'
end
