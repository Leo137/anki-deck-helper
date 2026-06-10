# frozen_string_literal: true

module Dictionary
  module Meaning
    class PartOfSpeech < ApplicationRecord
      self.table_name = 'dictionary_meaning_part_of_speeches'

      belongs_to :dictionary_meaning, class_name: 'Dictionary::Meaning', foreign_key: 'dictionary_meaning_id'
    end
  end
end
