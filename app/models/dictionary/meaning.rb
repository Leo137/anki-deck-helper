class Dictionary::Meaning < ApplicationRecord
  belongs_to :dictionary_entry, class_name: 'Dictionary::Entry', foreign_key: 'dictionary_entry_id'

  has_many :definitions, foreign_key: 'dictionary_meaning_id', dependent: :destroy
  has_many :fields, foreign_key: 'dictionary_meaning_id', dependent: :destroy
  has_many :misc_tags, foreign_key: 'dictionary_meaning_id', dependent: :destroy
  has_many :part_of_speeches, foreign_key: 'dictionary_meaning_id', dependent: :destroy
end
