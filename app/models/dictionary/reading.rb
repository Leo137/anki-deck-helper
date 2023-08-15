class Dictionary::Reading < ApplicationRecord
  belongs_to :dictionary_entry, class_name: 'Dictionary::Entry', foreign_key: 'dictionary_entry_id'
end
