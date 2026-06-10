# frozen_string_literal: true

class Dictionary < ApplicationRecord
  self.table_name = 'dictionaries'

  belongs_to :language
  has_many :meanings, class_name: 'Dictionary::Meaning', dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :language_id }

  def self.find_or_create_for!(name:, language:)
    lang = Language.find_or_create_by_code!(language)
    find_or_create_by!(name:, language: lang)
  end
end
