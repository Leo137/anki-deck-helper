# frozen_string_literal: true

class Dictionary
  class Reading < ApplicationRecord
    self.table_name = 'dictionary_readings'

    belongs_to :dictionary_entry, class_name: 'Dictionary::Entry', foreign_key: 'dictionary_entry_id'
  end
end
