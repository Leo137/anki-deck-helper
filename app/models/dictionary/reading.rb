# frozen_string_literal: true

module Dictionary
  class Reading < ApplicationRecord
    belongs_to :dictionary_entry, class_name: 'Dictionary::Entry', foreign_key: 'dictionary_entry_id'
  end
end
