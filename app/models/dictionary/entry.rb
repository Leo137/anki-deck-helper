class Dictionary::Entry < ApplicationRecord
  has_many :meanings, class_name: 'Dictionary::Meaning', foreign_key: 'dictionary_entry_id', dependent: :destroy
  has_many :readings, class_name: 'Dictionary::Reading', foreign_key: 'dictionary_entry_id', dependent: :destroy

  validates :text, presence: true, uniqueness: true
end
